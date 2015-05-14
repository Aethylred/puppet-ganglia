# NeSI Manifest to install the Ganglia web front end
#
# Do NOT use directly: use ganglia::webfrontend

class ganglia::web::install(
    $site_admin = 'admin@example.org'
  ){

  include ganglia::parameters

  # Need to figure out if the metaserver is a requirement for the webfrontend
  # include ganglia::metaserver

# We are going to install the 'latest stable' from the ganglia site
  package{$ganglia::parameters::web_package:
    ensure => purged,
  }

  include ganglia::web::download

  file{'web_makefile':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    path    => "${ganglia::parameters::web_dir}/Makefile",
    content => template("ganglia${ganglia::parameters::web_dir}/Makefile.erb"),
    require => File[$ganglia::parameters::web_dir],
  }

  exec{'install_web':
    cwd      => $ganglia::parameters::web_dir,
    user     => 'root',
    provider => 'shell',
    command  => 'make install',
    require  => File['web_makefile'],
    creates  => $ganglia::parameters::web_site_dir,
    notify   => Service['apache'],
  }

  case $::operatingsystem {
    Ubuntu:{
      exec{'disable_default_site':
        user    => 'root',
        path    => ['/usr/sbin','/usr/bin'],
        command => 'a2dissite default',
        onlyif  => 'test -e /etc/apache2/sites-enabled/*default',
        notify  => Service['apache'],
      }
      file{'ganglia2_site':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        path    => '/etc/apache2/sites-enabled/ganglia2',
        content => template('ganglia/ganglia2.erb'),
        require => Exec['install_web'],
        notify  => Service['apache'],
      }
      exec{'enable_ganglia_site':
        user    => 'root',
        path    => ['/usr/sbin','/usr/bin'],
        command => 'a2ensite ganglia2',
        creates => '/etc/apache2/sites-enabled/ganglia2',
        notify  => Service['apache'],
        require => [File['ganglia2_site'],Exec['disable_default_site']],
      }
    }
    default: {
      # Do nothing
    }
  }

}
