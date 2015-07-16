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
          %r{^RRDCACHED_ADDRESS=}
        ) }
        # init.d script content
        it { should contain_file('gmetad_init_script').with_content(
          %r{#{expects[:gmetad_initd_pkg]}}
        ) }
      end
      describe 'with no parameters' do
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
      describe 'when when installing from subversion' do
        let :params do
          { :provider => 'svn' }
        end
        it { should contain_class('ganglia::core::build') }
      end
      describe 'when when installing from git' do
        let :params do
          { :provider => 'git' }
        end
        it { should contain_class('ganglia::core::build') }
      end
      describe 'when when installing from source' do
        let :params do
          { :provider => 'source' }
        end
        it { should contain_class('ganglia::core::build') }
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
