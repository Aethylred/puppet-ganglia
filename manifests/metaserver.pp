# NeSI Ganglia metaserver manifest

class ganglia::metaserver(
  $cluster_name = 'mycluster',
  $data_sources = ['localhost']
){
  case $operatingsystem {
    Ubuntu:{
      class{'ganglia::core::install':
        cluster_name => $cluster_name,
        data_sources => $data_sources,
        with_gametad => true,
      }
    }
    default:{warning{"Ganglia not configured for $operatingsystem":}}
  }
}