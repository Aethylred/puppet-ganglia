require 'spec_helper'

describe 'ganglia::core::install::repo', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      describe 'with no parameters' do
        it { should contain_file('core_repo_download_dir').with(
          'ensure' => 'directory',
          'path'   => '/usr/src/ganglia-git-release-3.7'
        ) }
        it { should contain_vcsrepo('/usr/src/ganglia-git-release-3.7').with(
            'ensure'   => 'present',
            'provider' => 'git',
            'source'   => 'https://github.com/ganglia/monitor-core.git',
            'revision' => 'release/3.7'
        ) }
        it { should contain_file('ganglia_core_source_dir').with(
          'ensure' => 'link',
          'path'   => '/usr/src/ganglia',
          'target' => '/usr/src/ganglia-git-release-3.7'
        ) }
      end
      describe 'when given parameters' do
        let :params do
          { :repo_uri     => 'https://svn.example.org/ganglia2/trunk',
            :repo_ref     => 'master',
            :provider     => 'svn',
            :core_src_dir => '/src/ganglia2',
          }
        end
        it { should contain_file('core_repo_download_dir').with(
          'ensure' => 'directory',
          'path'   => '/src/ganglia2-svn-master'
        ) }
        it { should contain_vcsrepo('/src/ganglia2-svn-master').with(
            'ensure'   => 'present',
            'provider' => 'svn',
            'source'   => 'https://svn.example.org/ganglia2/trunk',
            'revision' => 'master'
        ) }
        it { should contain_file('ganglia_core_source_dir').with(
          'ensure' => 'link',
          'path'   => '/src/ganglia2',
          'target' => '/src/ganglia2-svn-master'
        ) }
      end
      describe 'when given a reference with a lot of slashes' do
        let :params do
          { :repo_ref => 'this/ref/is/full/of/slashes' }
        end
        it { should contain_file('core_repo_download_dir').with(
          'ensure' => 'directory',
          'path'   => '/usr/src/ganglia-git-this-ref-is-full-of-slashes'
        ) }
        it { should contain_vcsrepo('/usr/src/ganglia-git-this-ref-is-full-of-slashes').with_revision('this/ref/is/full/of/slashes') }
        it { should contain_file('ganglia_core_source_dir').with_target('/usr/src/ganglia-git-this-ref-is-full-of-slashes') }
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
