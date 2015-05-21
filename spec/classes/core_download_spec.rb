require 'spec_helper'

describe 'ganglia::core::download', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      describe "with no parameters" do
        it{ should contain_class('ganglia::params') }
        it{ should contain_file(expects[:src_root]).with_ensure('directory') }
        it{ should contain_file(expects[:src_version_dir]).with(
          'ensure'  => 'directory',
          'recurse' => true,
          'owner'   => 'root',
          'group'   => 'root',
          'require' => 'Exec[get_core]'
        ) }
        it{ should contain_file(expects[:src_dir]).with(
          'ensure'  => 'link',
          'path'    => expects[:src_dir],
          'target'  => expects[:src_version_dir],
          'require' => "File[#{expects[:src_version_dir]}]"
        ) }
        it{ should contain_exec('get_core').with(
          'cwd'     => expects[:src_root],
          'path'    => ['/usr/bin','/bin'],
          'user'    => 'root',
          'command' => "wget -O - #{expects[:core_source_url]}|tar xzv",
          'creates' => expects[:src_version_dir],
          'require' => "File[#{expects[:src_root]}]"
        ) }
      end
    end
  end
end
