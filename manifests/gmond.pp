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
  $reciever               = true,
  $host_dmax              = '0',
  $cleanup_threshold      = '300',
  $gexec                  = false,
  $send_metadata_interval = '0',
  $location               = 'unspecified',
  $cluster                = undef
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
      $concat_ensure    = 'present'
    }
    default: {
      $package_ensure   = 'absent'
      $file_ensure      = 'absent'
      $directory_ensure = 'absent'
      $service_ensure   = 'stopped'
      $service_enable   = false
      $concat_ensure    = 'absent'
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

  concat{$config_file:
    ensure => $concat_ensure
  }

  concat::fragment{'gmond.conf_header':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_header_fragment.erb'),
    order   => 'A000'
  }

  if $cluster {
    Concat::Fragment <<| tag == "${cluster}_ganglia_cluster" |>> {
      target => $config_file,
      order  => 'B000'
    }
    if ! $mute {
      Concat::Fragment <<| tag == "${cluster}_ganglia_cluster_ganglia_udp_send" |>> {
        target => $config_file,
        order  => 'D500'
      }
    }
    if ! $deaf or $reciever {
      Concat::Fragment <<| tag == "${cluster}_ganglia_cluster_ganglia_udp_recv" |>> {
        target => $config_file,
        order  => 'E500'
      }
      Concat::Fragment <<| tag == "${cluster}_ganglia_cluster_ganglia_tcp_accept" |>> {
        target => $config_file,
        order  => 'F500'
      }
    }
  } else {
    concat::fragment{'unspecified_ganglia_cluster':
      target  => $config_file,
      content => template('ganglia/cluster/unspecified_cluster.erb'),
      order   => 'B000'
    }
  }

  concat::fragment{'gmond.conf_location':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_location_fragment.erb'),
    order   => 'C000'
  }

  concat::fragment{'gmond.conf_udp_send_channel_header':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_udp_send_channel_header_fragment.erb'),
    order   => 'D000'
  }

  concat::fragment{'gmond.conf_udp_recv_channel_header':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_udp_recv_channel_header_fragment.erb'),
    order   => 'E000'
  }

  concat::fragment{'gmond.conf_tcp_accept_channel_header':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_tcp_accept_channel_header_fragment.erb'),
    order   => 'F000'
  }

  # This fragment currently holds all the parts of the configuration that is
  # not yet automated
  concat::fragment{'gmond.conf_footer':
    target  => $config_file,
    content => template('ganglia/config/gmond.conf_footer_fragment.erb'),
    order   => 'C000'
  }

}
