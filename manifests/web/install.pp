# NeSI Manifest to install the Ganglia web front end
#
# Do NOT use directly: use ganglia::webfrontend

class ganglia::web::install {

  include web::apache
  include web::apache::mod_php
  include ganglia::parameters

  # Need to figure out if the metaserver is a requirement for the webfrontend
  # include ganglia::metaserver

# We are going to install the 'latest stable' from the ganglia site
  package{$ganglia::parameters::web_package:
    ensure => purged,
  }

  include ganglia::web::download

  file{'web_makefile':
    ensure  => file,
    owner   => root,
    group   => root,
    path    => "${ganglia::parameters::web_dir}/Makefile",
    content => template("ganglia${ganglia::parameters::web_dir}/Makefile.erb"),
    require => File[$ganglia::parameters::web_dir],
  }

  exec{'install_web':
    cwd       => $ganglia::parameters::web_dir,
    user      => root,
    provider  => shell,
    command   => 'make install',
    require   => File['web_makefile'],
    creates   => $ganglia::parameters::web_site_dir,
    notify    => Service['apache'],
  }

  case $operatingsystem {
    Ubuntu:{
      exec{'disable_default_site':
        user      => root,
        path      => ['/usr/sbin','/usr/bin'],
        command   => 'a2dissite default',
        onlyif    => 'test -e /etc/apache2/site-enable/*default',
      }
    }
  } 

}