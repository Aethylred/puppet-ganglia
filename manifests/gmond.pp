# Configures the Gangla Monitoring Daemon gmond
class ganglia::gmond (
  $ensure                 = 'running',
  $provider               = 'package',
  $packages               = $ganglia::params::gmond_packages,
  $config_dir             = $ganglia::params::config_dir,
  $prefix                 = undef,
  $daemonize              = true,
  $setuid                 = true,
  $user                   = 'ganglia',
  $debug_level            = '0',
  $max_udp_msg_len        = '1472',
  $mute                   = false,
  $deaf                   = false,
  $host_dmax              = '0',
  $cleanup_threshold      = '300',
  $gexec                  = false,
  $send_metadata_interval = '0'
) inherits ganglia::params {

  validate_re($ensure, ['running','present','stopped','absent'])
  validate_re($provider,['package','source','git','svn'])
  validate_bool($daemonize, $setuid, $mute, $deaf, $gexec)
  validate_integer($debug_level, $max_udp_msg_len, $host_dmax, $cleanup_threshold, $send_metadata_interval)

  $config_file = "${config_dir}/gmond.conf"

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
    $gmond_bin = "${prefix}/sbin/gmond"
  } else {
    case $provider {
      'package': {
        $gmond_bin = "${ganglia::params::package_prefix}/sbin/gmond"
      }
      default: {
        $gmond_bin = "${ganglia::params::build_prefix}/sbin/gmond"
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

  file{'gmond_config_file':
    ensure  => $file_ensure,
    path    => $config_file,
    content => template('ganglia/gmond.conf.erb')
  }

}
