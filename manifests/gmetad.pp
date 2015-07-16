# Sets up the Ganglia metadata daemon, gmetad
class ganglia::gmetad (
  $ensure            = 'running',
  $provider          = 'package',
  $packages          = $ganglia::params::gmetad_packages,
  $config_dir        = $ganglia::params::config_dir,
  $prefix            = undef,
  $rrdcached_address = undef,
  $scalable          = false,
  $gridname          = undef,
  $authority         = undef,
  $trusted_hosts     = undef,
  $all_trusted       = false,
  $setuid            = true,
  $setuid_username   = undef,
  $xml_port          = undef,
  $interactive_port  = undef,
  $server_threads    = undef,
  $rrd_rootdir       = undef,
  $case_sensitive    = false
) inherits ganglia::params {

  validate_bool($scalable, $all_trusted, $setuid, $case_sensitive)
  validate_string($gridname, $authority, $setuid_username)
  if $xml_port {
    validate_integer($xml_port)
  }
  if $interactive_port {
    validate_integer($interactive_port)
  }
  if $server_threads {
    validate_integer($server_threads)
  }
  if $rrd_rootdir {
    validate_absolute_path($rrd_rootdir)
  }
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
    path    => $ganglia::params::gmetad_init_script,
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
