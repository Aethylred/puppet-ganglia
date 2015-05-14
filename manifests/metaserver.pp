# NeSI Ganglia metaserver manifest

class ganglia::metaserver(
  $cluster_name   = 'MyCluster',
  $cluster_url    = 'http://cluster.example.org',
  $data_sources   = [{cluster_name => 'MyCluster', cluster_hosts => ['localhost']}],
  $latlong        = '0,0',
  $owner          = 'Nobody',
  $grid_name      = false,
  $grid_authority = false
){
  case $::operatingsystem {
    Ubuntu:{
      class{'ganglia::core::install':
        cluster_name   => $cluster_name,
        cluster_url    => $cluster_url,
        data_sources   => $data_sources,
        latlong        => $latlong,
        owner          => $owner,
        grid_name      => $grid_name,
        grid_authority => $grid_authority,
        with_gmetad    => true,
      }
    }
    default:{warning{"Ganglia metaserver not configured for ${::operatingsystem}":}}
  }
}
