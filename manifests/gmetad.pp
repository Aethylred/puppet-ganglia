# Sets up the Ganglia metadata daemon, gmetad
class ganglia::gmetad (
  $ensure   = 'running',
  $provider = 'package',
  $packages = $ganglia::params::gmetad_packages
) inherits ganglia::params {

  validate_re($ensure, ['running','present','stopped','absent'])
  validate_re($provider,['package','source','git','svn'])

  case $ensure {
    'running','present': {
      $package_ensure = 'present'
      $file_ensure    = 'file'
      $service_ensure = 'running'
    }
    default: {
      $package_ensure = 'absent'
      $file_ensure    = 'absent'
      $service_ensure = 'stopped'
    }
  }

  case $provider {
    'package': {
      package{$packages:
        ensure => $package_ensure
      }
    }
    default: {
      # the validate_re means we can assume gmetad has been preinstalled
      require ganglia::core::build
    }
  }

}
