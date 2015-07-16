require 'spec_helper'

describe 'ganglia::gmetad', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      describe 'with no parameters' do
        expects[:gmetad_packages].each do |package|
          it { should contain_package(package).with_ensure('present') }
        end
        it { should_not contain_class('ganglia::core::build') }
        it { should contain_file('gmetad_config_file').with(
          'ensure'  => 'file',
          'path'    => '/etc/ganglia/gmetad.conf'
        ) }
        it { should contain_file('gmetad_sysconf_file').with(
          'ensure'  => 'file',
          'path'    => expects[:gmetad_sysconf]
        ) }
        it { should contain_file('gmetad_init_script').with(
          'ensure'  => 'file',
          'path'    => '/etc/init.d/gmetad',
          'require' => ['File[gmetad_sysconf_file]','File[gmetad_config_file]']
        ) }
        it { should contain_service('gmetad').with(
          'ensure'     => 'running',
          'enable'     => true,
          'hasrestart' => true,
          'hasstatus'  => expects[:gmetad_hasstatus],
          'require'    => 'File[gmetad_init_script]'
        ) }
        # sysconfig/default content
        it { should contain_file('gmetad_sysconf_file').without_content(
          %r{^RRDCACHED_ADDRESS=.*$}
        ) }
        # init.d script content
        it { should contain_file('gmetad_init_script').with_content(
          %r{#{expects[:gmetad_initd_pkg]}}
        ) }
        # Check config file content
        it { should contain_file('gmetad_config_file').with_content(
          %r{^scalable off$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^gridname .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^authority .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^trusted_hosts .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^all_trusted on$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^setuid on$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^setuid_username .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^xml_port .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^interactive_port .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^server threads .*$}
        ) }
        it { should contain_file('gmetad_config_file').without_content(
          %r{^rrd_rootdir .*$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^case_sensitive_hostnames 0$}
        ) }
      end
      describe 'when gmetad is stopped' do
        let :params do
          { :ensure => 'stopped' }
        end
        expects[:gmetad_packages].each do |package|
          it { should contain_package(package).with_ensure('absent') }
        end
        it { should_not contain_class('ganglia::core::build') }
        it { should contain_file('gmetad_config_file').with(
          'ensure'  => 'absent'
        ) }
        it { should contain_file('gmetad_sysconf_file').with(
          'ensure'  => 'absent'
        ) }
        it { should contain_file('gmetad_init_script').with(
          'ensure'  => 'absent'
        ) }
        it { should contain_service('gmetad').with(
          'ensure'     => 'stopped',
          'enable'     => false
        ) }
      end
      describe 'when when installing from packages' do
        let :params do
          { :provider => 'package' }
        end
        it { should_not contain_class('ganglia::core::build') }
        expects[:gmetad_packages].each do |package|
          it { should contain_package(package).with_ensure('present') }
        end
      end
      describe 'when when installing from custom packages' do
        let :params do
          { :provider => 'package',
            :packages => ['magic','pixie','dust']
          }
        end
        it { should_not contain_class('ganglia::core::build') }
        it { should contain_package('magic').with_ensure('present') }
        it { should contain_package('pixie').with_ensure('present') }
        it { should contain_package('dust').with_ensure('present') }
      end
      describe 'when customising install locations' do
        let :params do
          { :config_dir => '/opt/ganglia/etc',
            :prefix     => '/opt/ganglia'
          }
        end

        it { should contain_file('gmetad_config_file').with(
          'ensure'  => 'file',
          'path'    => '/opt/ganglia/etc/gmetad.conf'
        ) }
        case facts[:osfamily]
        when 'Debian'
          it { should contain_file('gmetad_init_script').with_content(
            %r{^DAEMON=/opt/ganglia/sbin/gmetad$}
          ) }
        when 'RedHat'
          it { should contain_file('gmetad_init_script').with_content(
            %r{^GMETAD=/opt/ganglia/sbin/gmetad$}
          ) }
        end
      end
      describe 'when when installing from subversion' do
        let :params do
          { :provider => 'svn' }
        end
        it { should contain_class('ganglia::core::build') }
        it { should contain_file('gmetad_init_script').with_content(
          %r{#{expects[:gmetad_initd_bld]}}
        ) }
      end
      describe 'when when installing from git' do
        let :params do
          { :provider => 'git' }
        end
        it { should contain_class('ganglia::core::build') }
        it { should contain_file('gmetad_init_script').with_content(
          %r{#{expects[:gmetad_initd_bld]}}
        ) }
      end
      describe 'when when installing from source' do
        let :params do
          { :provider => 'source' }
        end
        it { should contain_class('ganglia::core::build') }
        it { should contain_file('gmetad_init_script').with_content(
          %r{#{expects[:gmetad_initd_bld]}}
        ) }
      end
      describe 'when setting RRD cache address' do
        let :params do
          { :rrdcached_address => 'unix:/var/run/rrdcached/rrdcached.sock' }
        end
        it { should contain_file('gmetad_sysconf_file').with_content(
          %r{^RRDCACHED_ADDRESS=unix:/var/run/rrdcached/rrdcached.sock}
        ) }
      end
      describe 'when setting RRD cache address' do
        let :params do
          { :rrdcached_address => 'unix:/var/run/rrdcached/rrdcached.sock' }
        end
        it { should contain_file('gmetad_sysconf_file').with_content(
          %r{^RRDCACHED_ADDRESS=unix:/var/run/rrdcached/rrdcached.sock}
        ) }
      end
      describe 'when customising the configuration' do
        let :params do
          { :scalable          => true,
            :gridname          => 'This Grid',
            :authority         => 'https://some.ganglia.example.org/ganglia',
            :trusted_hosts     => ['this.host','that.host','10.0.0.1'],
            :all_trusted       => true,
            :setuid            => false,
            :setuid_username   => 'somebody',
            :xml_port          => '2020',
            :interactive_port  => '4040',
            :server_threads    => '28',
            :rrd_rootdir       => '/path/to/rrd',
            :case_sensitive    => true
          }
        end
        it { should contain_file('gmetad_config_file').with_content(
          %r{^scalable on$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^gridname "This Grid"$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^authority "https://some.ganglia.example.org/ganglia"$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^trusted_hosts this.host that.host 10.0.0.1$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^all_trusted on$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^setuid off$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^setuid_username "somebody"$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^xml_port 2020$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^interactive_port 4040$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^server threads 28$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^rrd_rootdir "/path/to/rrd"$}
        ) }
        it { should contain_file('gmetad_config_file').with_content(
          %r{^case_sensitive_hostnames 1$}
        ) }
      end
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    it { should raise_error(Puppet::Error,
      %r{The OS Family Unknown is not supported in the ganglia module}
    ) }
  end
end
