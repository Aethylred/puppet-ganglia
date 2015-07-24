# Defines a ganglia gmond tcp_accept_channel
define ganglia::channel::tcp_accept(
  $port       = '8649'
) {

  validate_integer($port)

  # This is a dummy concat file to act as a target, should never be realised
  @@concat{"/tmp/ganglia_${name}_tcp_accept_dummy":
    ensure => 'present'
  }

  @@concat::fragment{"${name}_tcp_accept_channel_declaration":
    target  => "/tmp/ganglia_${name}_tcp_accept_dummy",
    content => template('ganglia/channel/tcp_accept_channel_fragment.erb'),
    tag     => "${name}_ganglia_cluster_tcp_accept"
  }
}
