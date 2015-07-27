require 'spec_helper'

describe 'ganglia::channel::udp_recv', :type => :define do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    context "on #{os}" do
      let (:facts) { facts }
      let (:title) { 'test' }
    end
    # rspec-puppet does not currently test exported resources
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    let (:title) { 'test' }
    it { should compile }
  end
end
