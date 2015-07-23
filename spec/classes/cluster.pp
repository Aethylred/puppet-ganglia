# Defines a Ganglia gmond cluster and creates the required stored resources
define ganglia::cluster(
  $udp_send_host   = undef,
  $name            = $title,
  $owner           = 'unspecified',
  $latlong         = 'unspecified',
  $url             = 'unspecified',
  $udp_mcast_join  = undef,
  $udp_send_port   = '8649',
  $udp_send_ttl    = '1',
  $udp_recv_port   = '8649',
  $udp_recv_bind   = undef,
  $tcp_accept_port = '8649'
) inherits ganglia::params {

  if $udp_send_host and $udp_mcast_join {
    fail('Can not specify both udp_send_host or udp_mcast_join parameters, only one can be defined')
  }

  if ! $udp_send_host and ! $udp_mcast_join {
    fail('One of the udp_send_host or udp_mcast_join parameters must be provided.')
  }

  validate_integer($udp_recv_port, $udp_send_ttl, $udp_send_port, $tcp_accept_port)

  $cluster_fragment = template('ganglia/cluster/cluster_fragment.erb')
  $udp_send_channel_fragment = template('ganglia/cluster/udp_send_channel_fragment.erb')
  $udp_recv_channel_fragment = template('ganglia/cluster/udp_recv_channel_fragment.erb')
  $tcp_accept_channel_fragment = template('ganglia/cluster/tcp_accept_channel_fragment.erb')
}
