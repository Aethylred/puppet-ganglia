# NeSI Ganglia manifest for installing the web front end

class ganglia::web(
    $site_admin = 'admin@example.org'
  ){
  case $::operatingsystem {
    Ubuntu:{
      class{'ganglia::web::install':
        site_admin => $site_admin,
      }
    }
    default:{warning{"Ganglia web interface is not configured for ${::operatingsystem}":}}
  }
}
