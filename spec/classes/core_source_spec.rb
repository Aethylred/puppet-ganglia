require 'spec_helper'

describe 'ganglia::core::install::source', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      describe 'with no parameters' do
        it { should contain_file('core_source_download_dir').with(
          'ensure' => 'directory',
          'path'   => '/usr/src/ganglia-3.7.1'
        ) }
        it { should contain_exec('get_core_source_tarball').with(
          'path'    => ['/usr/bin','/bin'],
          'command' => "wget -O - http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/3.7.1/ganglia-3.7.1.tar.gz|tar xzv -C /usr/src/ganglia-3.7.1 --strip-components=1",
          'creates' => '/usr/src/ganglia-3.7.1/README',
          'require' => 'File[core_source_download_dir]'
        ) }
        it { should contain_file('ganglia_core_source_dir').with(
          'ensure' => 'link',
          'path'   => '/usr/src/ganglia',
          'target' => '/usr/src/ganglia-3.7.1'
        ) }
      end
      describe 'when given parameters' do
        let :params do
          { :source_uri   => 'https://somewhere.org/this.tar.gz',
            :core_version => '4.0.0',
            :core_src_dir => '/src/ganglia'
          }
        end
        it { should contain_file('core_source_download_dir').with(
          'ensure' => 'directory',
          'path'   => '/src/ganglia-4.0.0'
        ) }
        it { should contain_exec('get_core_source_tarball').with(
          'path'    => ['/usr/bin','/bin'],
          'command' => "wget -O - https://somewhere.org/this.tar.gz|tar xzv -C /src/ganglia-4.0.0 --strip-components=1",
          'creates' => '/src/ganglia-4.0.0/README',
          'require' => 'File[core_source_download_dir]'
        ) }
        it { should contain_file('ganglia_core_source_dir').with(
          'ensure' => 'link',
          'path'   => '/src/ganglia',
          'target' => '/src/ganglia-4.0.0'
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
