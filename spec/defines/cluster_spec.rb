require 'spec_helper'

describe 'ganglia::cluster', :type => :define do

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
      describe 'with setting both send host and multicast join' do
        let :params do
          {
            :udp_mcast_join => '10.0.0.1',
            :udp_send_host => 'ganglia.example.org'
          }
        end
        it { should raise_error(Puppet::Error,
          %r{Can not specify both host or mcast_join parameters, only one can be defined}
        ) }
      end
      describe 'when specifying a multicast join' do
        let :params do
          {
            :udp_mcast_join => '10.0.0.1'
          }
        end
        it { should contain_ganglia__channel__udp_send('test_ganglia_cluster').with(
          'host'       => nil,
          'mcast_join' => '10.0.0.1',
          'port'       => '8649',
          'ttl'        => '1'
        ) }
        it { should contain_ganglia__channel__udp_recv('test_ganglia_cluster').with(
          'bind'       => nil,
          'mcast_join' => '10.0.0.1',
          'port'       => '8649'
        ) }
        it { should contain_ganglia__channel__tcp_accept('test_ganglia_cluster').with(
          'port'       => '8649'
        ) }
      end
      describe 'when specifying a send host' do
        let :params do
          {
            :udp_send_host => 'ganglia.example.org'
          }
        end
        it { should contain_ganglia__channel__udp_send('test_ganglia_cluster').with(
          'host'       => 'ganglia.example.org',
          'mcast_join' => nil,
          'port'       => '8649',
          'ttl'        => '1'
        ) }
        it { should contain_ganglia__channel__udp_recv('test_ganglia_cluster').with(
          'bind'       => nil,
          'mcast_join' => nil,
          'port'       => '8649'
        ) }
        it { should contain_ganglia__channel__tcp_accept('test_ganglia_cluster').with(
          'port'       => '8649'
        ) }
      end
      describe 'when customising the udp send channel' do
        let :params do
          {
            :udp_send_host => 'ganglia.example.org',
            :udp_send_port => '444',
            :udp_send_ttl  => '6'
          }
        end
        it { should contain_ganglia__channel__udp_send('test_ganglia_cluster').with(
          'host'       => 'ganglia.example.org',
          'mcast_join' => nil,
          'port'       => '444',
          'ttl'        => '6'
        ) }
      end
      describe 'when customising the udp recieve host' do
        let :params do
          {
            :udp_recv_bind  => '10.0.0.1',
            :udp_mcast_join => '10.1.1.1',
            :udp_recv_port  => '888'
          }
        end
        it { should contain_ganglia__channel__udp_recv('test_ganglia_cluster').with(
          'bind'       => '10.0.0.1',
          'mcast_join' => '10.1.1.1',
          'port'       => '888'
        ) }
      end
      describe 'when customising tcp accept channel' do
        let :params do
          {
            :udp_send_host   => 'ganglia.example.org',
            :tcp_accept_port => '1212'
          }
        end
        it { should contain_ganglia__channel__tcp_accept('test_ganglia_cluster').with(
          'port'       => '1212'
        ) }
      end
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    let (:title) { 'test' }
    # it { should compile }
  end
end
