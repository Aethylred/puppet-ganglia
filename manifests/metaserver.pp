# NeSI Ganglia metaserver manifest

class ganglia::metaserver(
  $cluster_name = 'mycluster',
  $cluster_url  = 'http://cluster.example.org',
  $data_sources = ['localhost'],
  $latlong      = '0,0',
  $owner        = 'Nobody'
){
  case $operatingsystem {
    Ubuntu:{
      class{'ganglia::core::install':
        cluster_name  => $cluster_name,
        cluster_url   => $cluster_url,
        data_sources  => $data_sources,
        latlong       => $latlong,
        owner         => $owner,
        with_gametad  => true,
      }
    }
    default:{warning{"Ganglia not configured for $operatingsystem":}}
  }
}