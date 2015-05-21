require 'spec_helper'

describe 'ganglia::core::install', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      describe 'with no parameters' do
        it{ should contain_class('ganglia::params') }
        it{ should contain_class('ganglia::core::download') }
        it{ should contain_package(expects[:metaserver_package]).with_ensure('absent') }
        it{ should contain_package(expects[:monitor_package]).with_ensure('absent') }
        expects[:base_packages].each do | dep_package |
          it{ should contain_package(dep_package).with_ensure('installed') }
        end
        case facts[:osfamily]
        when 'RedHat'
          it{ should contain_exec('dev_tools').with(
            'user'    => 'root',
            'path'    => ['/usr/bin'],
            'command' => "yum -y groupinstall 'Development Tools'",
            'unless'  => "yum -y groupinstall 'Development Tools' --downloadonly",
            'timeout' => '0600',
            'require' => 'Package[yum-plugin-downloadonly]'
          ) }
        else
          it{ should_not contain_exec('dev_tools') }
        end
        it { should contain_user('nobody').with_ensure('present') }
        it { should contain_exec('configure_core').with(
          'cwd'     => expects[:src_dir],
          'user'    => 'root',
          'command' => "#{expects[:src_dir]}/configure #{expects[:configure_opts]}",
          'creates' => "#{expects[:src_dir]}/config.status",
          'require' => expects[:configure_require]
        ) }
        it { should contain_exec('make_core').with(
          'cwd'      => expects[:src_dir],
          'user'     => 'root',
          'provider' => 'shell',
          'command'  => 'make',
          'require'  => 'Exec[configure_core]',
          'creates'  => "#{expects[:src_dir]}/gmond/gmond"
        ) }
        it { should contain_service(expects[:metaserver_service]).with(
          'ensure'     => 'stopped',
          'enable'     => false,
          'hasrestart' => true,
          'hasstatus'  => false
        ) }
        it { should contain_file(expects[:monitor_conf]).with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'root',
          'path'    => expects[:monitor_conf],
          'require' => "File[#{expects[:config_dir]}]",
          'notify'  => "Service[#{expects[:monitor_service]}]"
        ) }
        it { should contain_file(expects[:monitor_init]).with(
          'ensure'  => 'file',
          'path'    => expects[:monitor_init],
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0755',
          'require' => 'Exec[install_core]',
          'notify'  => "Service[#{expects[:monitor_service]}]"
        ) }
      end
      describe 'with metadata service' do
        let :params do
            { :with_gmetad => true }
          end
        expects[:gmetad_packages].each do | dep_package |
          it{ should contain_package(dep_package).with_ensure('installed') }
        end
        expects[:base_packages].each do | dep_package |
          it{ should contain_package(dep_package).with_ensure('installed') }
        end
        it { should contain_exec('configure_core').with(
          'cwd'     => expects[:src_dir],
          'user'    => 'root',
          'command' => "#{expects[:src_dir]}/configure --with-gmetad #{expects[:configure_opts]}",
          'creates' => "#{expects[:src_dir]}/config.status",
          'require' => expects[:gmetad_config_req]
        ) }
        it { should contain_service(expects[:metaserver_service]).with(
          'ensure'     => 'running',
          'enable'     => true,
          'hasrestart' => true,
          'hasstatus'  => false
        ) }
      end
    end
  end
end
