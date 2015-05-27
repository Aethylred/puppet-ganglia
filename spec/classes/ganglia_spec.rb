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
          'core_src_dir' => '/usr/src/ganglia',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::repo') }
      end
      describe 'when installing from git' do
        let :params do
          { :provider => 'git' }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'git',
          'core_src_dir' => '/usr/src/ganglia',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
      end
      describe 'when installing from subversion' do
        let :params do
          { :provider => 'svn' }
        end
        it { should contain_class('ganglia::core::install::repo').with(
          'repo_uri'     => nil,
          'provider'     => 'svn',
          'core_src_dir' => '/usr/src/ganglia',
          'before'       => 'Anchor[post_core_install]'
        ) }
        it { should_not contain_class('ganglia::core::install::source') }
      end
      describe 'when installing from packages' do
        let :params do
          { :provider => 'package' }
        end
        it { should raise_error(Puppet::Error,
          %r{Packages are installed by component, not via the core installer}
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
