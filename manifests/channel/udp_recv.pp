# Defines a ganglia gmond udp_recv_channel
define ganglia::channel::udp_recv(
  $bind       = undef,
  $mcast_join = undef,
  $port       = '8649'
) {

  validate_integer($port)
  if $bind {
    validate_string($bind)
  }
  if $mcast_join{
    validate_string($mcast_join)
  }

  # This is a dummy concat file to act as a target, should never be realised
  @@concat{"/tmp/ganglia_${name}_udp_recv_dummy":
    ensure => 'present'
  }

  @@concat::fragment{"${name}_udp_recv_channel_declaration":
    target  => "/tmp/ganglia_${name}_udp_recv_dummy",
    content => template('ganglia/channel/udp_recv_channel_fragment.erb'),
    tag     => "${name}_ganglia_cluster_udp_recv"
  }
}
