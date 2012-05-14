# NeSI Ganglia metaserver install manifest
#
# Do NOT use directly use ganglia::metaserver or ganglia::client

class ganglia::core::install(
  $cluster_name = 'mycluster',
  $data_sources = ['localhost'],
  $with_gametad = false
){

  include ganglia::parameters
  include ganglia::core::download

  # Installing the latest stable from the Ganglia web site, so no packages please 
  package{$ganglia::parameters::metaserver_package: ensure => purged}

  # Dependencies
  if $with_gametad {
    package{'build-essential': ensure => installed}
    package{'rrdtool': ensure => installed}
    package{'libapr1-dev': ensure => installed}
    package{'pkg-config': ensure => installed}
    package{'libconfuse-dev': ensure => installed}
    package{'libexpat1-dev': ensure => installed}
    package{'libpcre3-dev': ensure => installed}
    package{'librrd-dev': ensure => installed}
  } 

  user{'nobody': ensure => present}

  exec{'configure_core':
    cwd     => $ganglia::parameters::src_dir,
    user    => root,
    command => $with_gametad ? {
      true      => "${ganglia::parameters::src_dir}/configure --with-gmetad ${ganglia::parameters::configure_opts}",
      default   => "${ganglia::parameters::src_dir}/configure ${ganglia::parameters::configure_opts}",
    },
    creates => "${ganglia::parameters::src_dir}/config.status",
    require => $with_gametad ? {
      true      => [File[$ganglia::parameters::src_dir],Package['build-essential','libapr1-dev','pkg-config','libconfuse-dev','libexpat1-dev','libpcre3-dev','librrd-dev','rrdtool']],
      default   => [File[$ganglia::parameters::src_dir],Package['build-essential','libapr1-dev','pkg-config','libconfuse-dev','libexpat1-dev','libpcre3-dev','librrd-dev','rrdtool']],
    }
  }

  exec{'make_core':
    cwd       => $ganglia::parameters::src_dir,
    user      => root,
    provider  => shell,
    command   => 'make',
    require   => Exec['configure_core'],
    creates   => "${ganglia::parameters::src_dir}/gmond/gmond",
  }

  exec{'install_core':
    cwd       => $ganglia::parameters::src_dir,
    user      => root,
    provider  => shell,
    command   => 'make install',
    require   => Exec['configure_core'],
    creates   => $ganglia::parameters::metaserver_bin,
  }

  if $with_gametad {
    file{'metaserver_init':
      ensure  => file,
      path    => $ganglia::parameters::metaserver_init,
      owner   => root,
      group   => root,
      mode    => '0755',
      source  => template("ganglia${ganglia::parameters::metaserver_init}.erb"),
      require => Exec['install_core'],
    }
    file{$ganglia::parameters::rrd_parentdir:
      ensure  => directory,
      owner   => root,
      group   => root,
      require => Exec['install_core'],
    }

    file{$ganglia::parameters::rrd_rootdir:
      ensure  => directory,
      owner   => nobody,
      group   => root,
      require => [Exec['install_core'],File[$ganglia::parameters::rrd_parentdir]],
    }

    file{$ganglia::parameters::metaserver_conf:
      ensure  => file,
      owner   => root,
      group   => root,
      path    => $ganglia::parameters::metaserver_conf,
      content => template("ganglia${ganglia::parameters::metaserver_conf}.erb"),
      require => File[$ganglia::parameters::config_dir,$ganglia::parameters::rrd_parentdir,$ganglia::parameters::rrd_rootdir],
      notify  => Service[$ganglia::parameters::metaserver_service],
    }

    service{$ganglia::parameters::metaserver_service:
      ensure      => running,
      enable      => true,
      hasrestart  => true,
      hasstatus   => false,
    }
  } else {
    service{$ganglia::parameters::metaserver_service:
      ensure      => stopped,
      enable      => true,
      hasrestart  => true,
      hasstatus   => false,
    }
  }

  file{$ganglia::parameters::config_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => Exec['install_core'],
  }



}