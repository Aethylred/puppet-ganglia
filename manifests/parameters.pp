# NeSI global variables etc.

class ganglia::parameters{
  case $operatingsystem{
    Ubuntu: {
      $webfrontend_package    = 'ganglia-webfrontend'
      $metaserver_package     = 'gmetad'
    }
  }

# Set software versions
  $web_version        = '3.4.2'
  $core_version       = '3.3.7'
  $pyclient_version   = '3.3.0'

# Set software source URLs and files
  $core_source_url    = "http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/${core_version}/ganglia-${core_version}.tar.gz"
  $core_source_file   = "ganglia-${core_version}.tar.gz"
}