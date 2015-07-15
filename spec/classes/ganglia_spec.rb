require 'spec_helper'

describe 'ganglia', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      describe 'with no parameters' do
        it { should contain_class('ganglia::core::install::source').with(
          'source_uri'   => nil,
          'core_src_dir' => expects[:core_src_dir],
          'core_version' => expects[:core_version],
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::repo') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => expects[:core_src_dir],
          'with_gmetad'    => false,
          'disable_python' => false,
          'enable_perl'    => false,
          'enable_status'  => false,
          'disable_sflow'  => false,
          'prefix'         => expects[:build_prefix],
          'dep_packages'   => expects[:dep_packages],
          'config_dir'     => expects[:config_dir]
        ) }
        it { should contain_file('ganglia_config_dir').with(
          'ensure' => 'directory',
          'path'   => '/etc/ganglia'
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'source',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/etc/ganglia',
          'prefix'            => nil,
          'rrdcached_address' => nil,
          'scalable'          => false,
          'gridname'          => nil,
          'authority'         => nil,
          'trusted_hosts'     => nil,
          'all_trusted'       => false,
          'setuid'            => true,
          'setuid_username'   => nil,
          'xml_port'          => nil,
          'interactive_port'  => nil,
          'server_threads'    => nil,
          'rrd_rootdir'       => nil,
          'case_sensitive'    => false
        ) }
      end
      describe 'when customising build from source' do
        let :params do
          { :provider       => 'source',
            :core_version   => '4.0.0',
            :source_uri     => 'https://example.org/ganglia.tar.gz',
            :prefix         => '/opt/ganglia',
            :core_src_dir   => '/src/ganglia2',
            :config_dir     => '/opt/ganglia/etc',
            :with_gmetad    => true,
            :disable_python => true,
            :enable_perl    => true,
            :enable_status  => true,
            :disable_sflow  => true,
            :dep_packages   => ['magical','package','dependencies'],
           }
        end
        it { should contain_class('ganglia::core::install::source').with(
          'source_uri'   => 'https://example.org/ganglia.tar.gz',
          'core_src_dir' => '/src/ganglia2',
          'core_version' => '4.0.0',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::repo') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => '/src/ganglia2',
          'with_gmetad'    => true,
          'disable_python' => true,
          'enable_perl'    => true,
          'enable_status'  => true,
          'disable_sflow'  => true,
          'prefix'         => '/opt/ganglia',
          'dep_packages'   => ['magical','package','dependencies'],
          'config_dir'     => '/opt/ganglia/etc'
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'source',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/opt/ganglia/etc',
          'prefix'            => '/opt/ganglia',
          'rrdcached_address' => nil
        ) }
      end
      describe 'when installing from git' do
        let :params do
          { :provider => 'git' }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'git',
          'repo_ref'     => expects[:core_repo_ref],
          'core_src_dir' => expects[:core_src_dir],
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => expects[:core_src_dir],
          'with_gmetad'    => false,
          'disable_python' => false,
          'enable_perl'    => false,
          'enable_status'  => false,
          'disable_sflow'  => false,
          'prefix'         => expects[:build_prefix],
          'dep_packages'   => expects[:dep_packages],
          'config_dir'     => expects[:config_dir]
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'git',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/etc/ganglia',
          'prefix'            => nil,
          'rrdcached_address' => nil
        ) }
      end
      describe 'when customising build from git' do
        let :params do
          { :provider       => 'git',
            :core_version   => '4.0.0',
            :repo_uri       => 'git@example.org/ganglia.git',
            :prefix         => '/opt/ganglia',
            :core_src_dir   => '/src/ganglia2',
            :config_dir     => '/opt/ganglia/etc',
            :with_gmetad    => true,
            :disable_python => true,
            :enable_perl    => true,
            :enable_status  => true,
            :disable_sflow  => true,
            :dep_packages   => ['magical','package','dependencies'],
           }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => 'git@example.org/ganglia.git',
          'provider'     => 'git',
          'repo_ref'     => expects[:core_repo_ref],
          'core_src_dir' => '/src/ganglia2',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => '/src/ganglia2',
          'with_gmetad'    => true,
          'disable_python' => true,
          'enable_perl'    => true,
          'enable_status'  => true,
          'disable_sflow'  => true,
          'prefix'         => '/opt/ganglia',
          'dep_packages'   => ['magical','package','dependencies'],
          'config_dir'     => '/opt/ganglia/etc'
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'git',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/opt/ganglia/etc',
          'prefix'            => '/opt/ganglia',
          'rrdcached_address' => nil
        ) }
      end
      describe 'when customising install from subversion' do
        let :params do
          { :provider       => 'svn',
            :core_version   => '4.0.0',
            :repo_uri       => 'https//somewhere.org/ganglia',
            :prefix         => '/opt/ganglia',
            :core_src_dir   => '/src/ganglia2',
            :config_dir     => '/opt/ganglia/etc',
            :with_gmetad    => true,
            :disable_python => true,
            :enable_perl    => true,
            :enable_status  => true,
            :disable_sflow  => true,
            :dep_packages   => ['magical','package','dependencies'],
           }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => 'https//somewhere.org/ganglia',
          'provider'     => 'svn',
          'repo_ref'     => expects[:core_repo_ref],
          'core_src_dir' => '/src/ganglia2',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => '/src/ganglia2',
          'with_gmetad'    => true,
          'disable_python' => true,
          'enable_perl'    => true,
          'enable_status'  => true,
          'disable_sflow'  => true,
          'prefix'         => '/opt/ganglia',
          'dep_packages'   => ['magical','package','dependencies'],
          'config_dir'     => '/opt/ganglia/etc'
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'svn',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/opt/ganglia/etc',
          'prefix'            => '/opt/ganglia',
          'rrdcached_address' => nil
        ) }
      end
      describe 'when installing from subversion' do
        let :params do
          { :provider => 'svn' }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'svn',
          'repo_ref'     => expects[:core_repo_ref],
          'core_src_dir' => expects[:core_src_dir],
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
        it { should contain_class('ganglia::core::build').with(
          'core_src_dir'   => expects[:core_src_dir],
          'with_gmetad'    => false,
          'disable_python' => false,
          'enable_perl'    => false,
          'enable_status'  => false,
          'disable_sflow'  => false,
          'prefix'         => expects[:build_prefix],
          'dep_packages'   => expects[:dep_packages],
          'config_dir'     => expects[:config_dir]
        ) }
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'stopped',
          'provider'          => 'svn',
          'packages'          => expects[:gmetad_packages],
          'config_dir'        => '/etc/ganglia',
          'prefix'            => nil,
          'rrdcached_address' => nil
        ) }
      end
      describe 'when specifying a repository reference with subversion' do
        let :params do
          { :provider => 'svn',
            :repo_ref => 'test'
           }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'svn',
          'repo_ref'     => 'test',
          'core_src_dir' => expects[:core_src_dir],
          'before'       => 'Anchor[post_core_install]'
        ) }
      end
      describe 'when specifying a repository reference with git' do
        let :params do
          { :provider => 'git',
            :repo_ref => 'test'
           }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'git',
          'repo_ref'     => 'test',
          'core_src_dir' => expects[:core_src_dir],
          'before'       => 'Anchor[post_core_install]'
        ) }
      end
      describe 'when installing from packages' do
        let :params do
          { :provider => 'package' }
        end
        it { should_not contain_class('ganglia::core::install::source') }
        it { should_not contain_class('ganglia::core::install::repo') }
        it { should_not contain_class('ganglia::core::build') }
      end
      describe 'when changing the configuration directory' do
        let :params do
          { :config_dir => '/opt/ganglia/etc' }
        end
        it { should contain_file('ganglia_config_dir').with(
          'ensure' => 'directory',
          'path'   => '/opt/ganglia/etc'
        ) }
      end
      describe 'when customising gmetad install' do
        let :params do
          { :gmetad_ensure           => 'running',
            :rrdcached_address       => 'unix:/opt/rrdcached/rrdcached.sock',
            :gmetad_packages         => ['magic','pixie','dust'],
            :gmetad_scalable         => true,
            :gmetad_gridname         => 'A Grid',
            :gmetad_authority        => 'https://some.ganglia.org/auth',
            :gmetad_trusted_hosts    => ['192.168.1.1','this.host','that.host'],
            :gmetad_all_trusted      => true,
            :gmetad_setuid           => false,
            :gmetad_setuid_username  => 'somebody',
            :gmetad_xml_port         => '8888',
            :gmetad_interactive_port => '9999',
            :gmetad_server_threads   => '12',
            :gmetad_rrd_rootdir      => '/path/to/rrd',
            :gmetad_case_sensitive   => false
          }
        end
        it { should contain_class('ganglia::gmetad').with(
          'ensure'            => 'running',
          'provider'          => 'source',
          'packages'          => ['magic','pixie','dust'],
          'config_dir'        => '/etc/ganglia',
          'prefix'            => nil,
          'rrdcached_address' => 'unix:/opt/rrdcached/rrdcached.sock',
          'scalable'          => true,
          'gridname'          => 'A Grid',
          'authority'         => 'https://some.ganglia.org/auth',
          'trusted_hosts'     => ['192.168.1.1','this.host','that.host'],
          'all_trusted'       => true,
          'setuid'            => false,
          'setuid_username'   => 'somebody',
          'xml_port'          => '8888',
          'interactive_port'  => '9999',
          'server_threads'    => '12',
          'rrd_rootdir'       => '/path/to/rrd',
          'case_sensitive'    => false
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
