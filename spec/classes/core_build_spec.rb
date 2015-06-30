require 'spec_helper'

describe 'ganglia::core::build', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      it { should contain_class('gcc') }
      describe 'with no parameters' do
        it { should_not contain_class('rrd') }
        expects[:dep_packages].each do | dep_package |
          it{ should contain_package(dep_package).with_ensure('installed') }
        end
        configure_require = expects[:dep_packages].map do | dep_package |
          "Package[#{dep_package}]"
        end
        configure_require.push('File[/usr/src/ganglia]')
        it { should contain_exec('configure_core').with(
          'cwd'     => '/usr/src/ganglia',
          'command' => '/usr/src/ganglia/configure --prefix=/usr/local --sysconfdir=/etc/ganglia',
          'creates' => '/usr/src/ganglia/config.status',
          'require' => configure_require
        ) }
        it { should contain_exec('make_core').with(
          'cwd'     => '/usr/src/ganglia',
          'command' => 'make',
          'require' => 'Exec[configure_core]',
          'creates' => '/usr/src/ganglia/gmond/gmond'
        ) }
      end
      describe 'when given parameters' do
        let :params do
          { :core_src_dir   => '/src/ganglia2',
            :with_gmetad    => true,
            :disable_python => true,
            :enable_perl    => true,
            :enable_status  => true,
            :disable_sflow  => true,
            :prefix         => '/opt/ganglia',
            :dep_packages   => 'magic_bag',
            :config_dir     => '/opt/ganglia/config'
          }
        end
        it { should contain_class('rrd') }
        it { should contain_exec('configure_core').with(
          'cwd'     => '/src/ganglia2',
          'command' => '/src/ganglia2/configure --with-gmetad --disable-python --enable-perl --enable-status --disable-sflow --prefix=/opt/ganglia --sysconfdir=/opt/ganglia/config',
          'creates' => '/src/ganglia2/config.status',
          'require' => [
            'Package[magic_bag]',
            'File[/src/ganglia2]'
          ]
        ) }
        it { should contain_exec('make_core').with(
          'cwd'     => '/src/ganglia2',
          'command' => 'make',
          'require' => 'Exec[configure_core]',
          'creates' => '/src/ganglia2/gmond/gmond'
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
