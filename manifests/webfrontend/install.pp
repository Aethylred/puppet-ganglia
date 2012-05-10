# NeSI Manifest to install the Ganglia web front end

class ganglia::webfrontend::install {

  include web::apache
  include web::apache::mod_php

  package{'ganglia-webfrontend':
    ensure => installed,
    require => Service['apache'],
  }

}