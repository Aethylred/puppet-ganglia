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
) {

  if $name == 'unspecified' {
    fail('A Ganglia cluster can not be named unspecified, this is reserved for no cluster')
  }

  validate_integer($udp_recv_port, $udp_send_ttl, $udp_send_port, $tcp_accept_port)

  # This is a dummy concat file to act as a target, should never be realised
  @@concat{"/tmp/ganglia_${name}_cluster_dummy":
    ensure => 'present'
  }

  @@concat::fragment{"${name}_ganglia_cluster":
    target  => "/tmp/ganglia_${name}_cluster_dummy",
    content => template('ganglia/cluster/cluster_fragment.erb'),
    tag     => "${name}_ganglia_cluster"
  }

  ganglia::channel::udp_send{"${name}_ganglia_cluster":
    host       => $udp_send_host,
    mcast_join => $udp_mcast_join,
    port       => $udp_send_port,
    ttl        => $udp_send_ttl,
  }

  ganglia::channel::udp_recv{"${name}_ganglia_cluster":
    bind       => $udp_recv_bind,
    mcast_join => $udp_mcast_join,
    port       => $udp_recv_port,
  }

  ganglia::channel::tcp_accept{"${name}_ganglia_cluster":
    port => $tcp_accept_port
  }

}
