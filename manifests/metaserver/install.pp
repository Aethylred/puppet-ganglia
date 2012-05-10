# NeSI Ganglia metaserver install manifest
#
# Do NOT use directly use ganglia::metaserver

class ganglia::metaserver::install{

  include ganglia::parameters
  # Installing the latest stable from the Ganglia web site, so no packages please 
  package{$ganglia::parameters::metaserver_package: ensure => purged}
}