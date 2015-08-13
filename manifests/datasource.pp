# Defines a Ganglia gmond cluster and creates the required stored resources
define ganglia::datasource(
  $interval = '15'
) {

  if $name == 'unspecified' {
    fail('A Ganglia cluster can not be named unspecified, this is reserved')
  }

  validate_integer($interval)

  # This is a dummy concat file to act as a target, should never be realised
  @@concat{"/tmp/ganglia_${name}_datasource_dummy":
    ensure => 'present'
  }

  @@concat::fragment{"${name}_ganglia_datasource":
    target  => "/tmp/ganglia_${name}_datasource_dummy",
    content => "data_source '${name}' ${interval}",
    tag     => "${name}_ganglia_datasource"
  }

}
