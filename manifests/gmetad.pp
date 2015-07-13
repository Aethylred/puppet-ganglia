# Sets up the Ganglia metadata daemon, gmetad
class ganglia::gmetad (
  $ensure            = 'running',
  $provider          = 'package',
  $packages          = $ganglia::params::gmetad_packages,
  $config_dir        = $ganglia::params::config_dir,
  $prefix            = undef,
  $rrdcached_address = undef
) inherits ganglia::params {

  validate_re($ensure, ['running','present','stopped','absent'])
  validate_re($provider,['package','source','git','svn'])

  $config_file = "${config_dir}/gmetad.conf"

  case $ensure {
    'running','present': {
      $package_ensure   = 'present'
      $file_ensure      = 'file'
      $directory_ensure = 'directory'
      $service_ensure   = 'running'
      $service_enable   = true
    }
    default: {
      $package_ensure   = 'absent'
      $file_ensure      = 'absent'
      $directory_ensure = 'absent'
      $service_ensure   = 'stopped'
      $service_enable   = false
    }
  }

  if $prefix {
    $gmetad_bin = "${prefix}/sbin/gmetad"
  } else {
    case $provider {
      'package': {
        $gmetad_bin = "${ganglia::params::package_prefix}/sbin/gmetad"
      }
      default: {
        $gmetad_bin = "${ganglia::params::build_prefix}/sbin/gmetad"
      }
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

  file{'gmetad_config_file':
    ensure  => $file_ensure,
    path    => $config_file,
    content => template('ganglia/gmetad.conf.erb')
  }

  file{'gmetad_sysconf_file':
    ensure  => $file_ensure,
    path    => $ganglia::params::gmetad_sysconf,
    content => template('ganglia/gmetad.sysconf.erb')
  }

  file{'gmetad_init_script':
    ensure  => $file_ensure,
    path    => $ganglia::params::init_script,
    content => template("ganglia/gmetad.init.${::osfamily}.erb"),
    require => File['gmetad_sysconf_file','gmetad_config_file']
  }

  service{'gmetad':
    ensure     => $service_ensure,
    enable     => $service_enable,
    hasrestart => true,
    hasstatus  => $ganglia::params::gmetad_hasstatus,
    require    => File['gmetad_init_script']
  }

}
