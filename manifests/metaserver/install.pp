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

  exec{'configure_core':
    cwd     => $ganglia::parameters::core_dir,
    user    => root,
    command => "${ganglia::parameters::core_dir}/configure",
    require => File[$ganglia::parameters::core_dir],
  }

}