# NeSI Ganglia metaserver manifest

class ganglia::metaserver {
  case $operatingsystem {
    Ubuntu:{include ganglia::metaserver::install}
    default:{warning{"Ganglia not configured for $operatingsystem":}}
  }
}