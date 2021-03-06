# NeSI Ganglia monitor manifest

class ganglia::monitor(
  $cluster_name = 'MyCluster',
  $cluster_url  = 'http://cluster.example.org',
  $latlong      = '0,0',
  $owner        = 'Nobody'
){
  case $::osfamily {
    'Debian','RedHat':{
      class{'ganglia::core::install':
        cluster_name   => $cluster_name,
        cluster_url    => $cluster_url,
        latlong        => $latlong,
        owner          => $owner,
        data_sources   => undef,
        grid_name      => undef,
        grid_authority => undef,
        with_gmetad    => false,
      }
    }
    default:{
      fail("Ganglia monitor not configured for ${::osfamily}")
    }
  }
}
