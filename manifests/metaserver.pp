# NeSI Ganglia metaserver manifest

class ganglia::metaserver(
  $cluster_name = 'mycluster',
  $data_sources = ['localhost']
){
  case $operatingsystem {
    Ubuntu:{
      class{'ganglia::metaserver::install':
        cluster_name => $cluster_name,
        data_sources => $data_sources,
      }
    }
    default:{warning{"Ganglia not configured for $operatingsystem":}}
  }
}