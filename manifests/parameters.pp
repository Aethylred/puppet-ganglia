# NeSI global variables etc.

class ganglia::parameters{
  case $operatingsystem{
    Ubuntu: {
      $webfrontend_package    = 'ganglia-webfrontend'
      $metaserver_package     = 'gmetad'
    }
  }
}