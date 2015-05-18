# NeSI Ganglia manifest for installing the web front end

class ganglia::web(
    $site_admin = 'admin@example.org'
  ){
  case $::osfamily {
    'Debian','RedHat':{
      class{'ganglia::web::install':
        site_admin => $site_admin,
      }
    }
    default:{
      fail("Ganglia web interface is not configured for ${::osfamily
    }")
    }
  }
}
