require 'spec_helper'

describe 'ganglia::channel::tcp_accept', :type => :define do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    context "on #{os}" do
      let (:facts) { facts }
      let (:title) { 'test' }
      # rspec-puppet does not currently test exported resources

      # describe 'with no parameters' do
      #   it { should contain_concat('/tmp/ganglia_test_tcp_accept_dummy').with_ensure('present')}
      #   it { should contain_concat__fragment('test_tcp_accept_channel_declaration').with_content(
      #     %r{  port = 8649>}
      #   ) }
      # end
      # describe 'when given a port' do
      #   let :params do
      #     {
      #       :port => '444'
      #     }
      #   end
      #   it { should contain_concat__fragment('test_tcp_accept_channel_declaration').with_content(
      #     %r{  port = 444>}
      #   ) }
      # end
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    let (:title) { 'test' }
    it { should compile }
  end
end
