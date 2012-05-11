# NeSI Ganglia metaserver install manifest
#
# Do NOT use directly use ganglia::metaserver

class ganglia::metaserver::install(
  $cluster_name = 'mycluster',
  $data_sources = ['localhost']
){

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

  file{'metaserver_init':
    ensure  => file,
    path    => $ganglia::parameters::metaserver_init,
    owner   => root,
    group   => root,
    mode    => '0755',
    source  => [
      "puppet:///modules/ganglia/${fqdn}/${ganglia::parameters::metaserver_init}",
      "puppet:///modules/ganglia/${operatingsystem}/${ganglia::parameters::metaserver_init}",
      "puppet:///modules/ganglia/${ganglia::parameters::metaserver_init}",
    ],
    require => Exec['install_core'],
  }

  file{$ganglia::parameters::config_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => Exec['install_core'],
  }

  file{$ganglia::parameters::metaserver_conf:
    ensure  => file,
    owner   => root,
    group   => root,
    path    => $ganglia::parameters::metaserver_conf,
    content => template("ganglia${ganglia::parameters::metaserver_conf}.erb"),
  }

}