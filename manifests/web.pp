# NeSI Ganglia manifest for installing the web front end

class ganglia::web {
  case $operatingsystem {
    Ubuntu:{include ganglia::web::install}
    default:{warning{"Ganglia web interface is not configured for $operatingsystem":}}
  }
}