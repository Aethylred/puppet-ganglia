require 'spec_helper'

describe 'ganglia::channel::udp_send', :type => :define do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    context "on #{os}" do
      let (:facts) { facts }
      let (:title) { 'test' }
      describe 'with no parameters' do
        it { should raise_error(Puppet::Error,
          %r{One of the host or mcast_join parameters must be provided}
        ) }
      end
      # rspec-puppet does not currently test exported resources
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    let (:title) { 'test' }
    let :params do
      {
        :mcast_join => 'localhost'
      }
    end
    it { should compile }
  end
end
