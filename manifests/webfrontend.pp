# NeSI Ganglia manifest for installing the web front end

class ganglia::webfrontend {
  case $operatingsystem {
    Ubuntu:{include ganglia::webfrontend::install}
    default:{warning{"Ganglia is not configured for $operatingsystem":}}
  }
}