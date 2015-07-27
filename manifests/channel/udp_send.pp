# Defines a ganglia gmond upd_send_channel
define ganglia::channel::udp_send(
  $host       = undef,
  $mcast_join = undef,
  $port       = '8649',
  $ttl        = '1'
) {

  validate_integer([$port, $ttl])
  if $host {
    validate_string($host)
  }
  if $mcast_join{
    validate_string($mcast_join)
  }

  if $host and $mcast_join {
    fail('Can not specify both host or mcast_join parameters, only one can be defined')
  }

  if ! $host and ! $mcast_join {
    fail('One of the host or mcast_join parameters must be provided.')
  }

  # This is a dummy concat file to act as a target, should never be realised
  @@concat{"/tmp/ganglia_${name}_udp_send_dummy":
    ensure => 'present'
  }

  @@concat::fragment{"${name}_udp_send_channel_fragment":
    target  => "/tmp/ganglia_${name}_udp_send_dummy",
    content => template('ganglia/channel/udp_send_channel_fragment.erb'),
    tag     => "${name}_ganglia_udp_send"
  }
}
