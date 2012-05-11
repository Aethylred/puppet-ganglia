# NeSI Ganglia metaserver install manifest
#
# Do NOT use directly use ganglia::metaserver

class ganglia::metaserver::install{

  include ganglia::parameters
  include ganglia::core::download

  # Installing the latest stable from the Ganglia web site, so no packages please 
  package{$ganglia::parameters::metaserver_package: ensure => purged}

  # Dependencies
  package{'build-essential': ensure => installed}
  package{'rrdtool': ensure => installed}
  package{'libapr1-dev': ensure => installed}
  package{'pkg-config': ensure => installed}
  package{'libconfuse-dev': ensure => installed}
  package{'libexpat1-dev': ensure => installed}
  package{'libpcre3-dev': ensure => installed}
  package{'librrd-dev': ensure => installed}

  exec{'configure_core':
    cwd     => $ganglia::parameters::core_dir,
    user    => root,
    command => "${ganglia::parameters::core_dir}/configure --with-gmetad",
    creates => "${ganglia::parameters::core_dir}/config.status",
    require => [
      File[$ganglia::parameters::core_dir],
      Package['build-essential','libapr1-dev','pkg-config','libconfuse-dev','libexpat1-dev','libpcre3-dev','librrd-dev','rrdtool']
    ],
  }

  exec{'make_core':
    cwd       => $ganglia::parameters::core_dir,
    user      => root,
    provider  => shell,
    command   => 'make',
    require   => Exec['configure_core'],
    creates   => "${ganglia::parameters::core_dir}/gmetad/gmetad",
  }

  exec{'install_core':
    cwd       => $ganglia::parameters::core_dir,
    user      => root,
    provider  => shell,
    command   => 'make install',
    require   => Exec['configure_core'],
    creates   => $ganglia::parameters::metaserver_bin,
  }

}