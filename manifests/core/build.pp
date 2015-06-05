# Build from source
class ganglia::core::build (
  $core_src_dir   = $ganglia::params::core_src_dir,
  $with_gmetad    = true,
  $disable_python = false,
  $enable_perl    = false,
  $enable_status  = false,
  $disable_sflow  = false,
  $dep_packages   = $ganglia::params::dep_packages,
  $config_dir     = $ganglia::params::config_dir
) inherits ganglia::params {

  require gcc

  if $with_gmetad {
    require rrd
    $gmetad_option = '--with-gmetad '
  } else {
    $gmetad_option = ''
  }

  if $disable_python {
    $disable_python_option = '--disable-python '
  } else {
    $disable_python_option = ''
  }

  if $enable_perl {
    $enable_perl_option = '--enable-perl '
  } else {
    $enable_perl_option = ''
  }

  if $enable_status {
    $enable_status_option = '--enable-status '
  } else {
    $enable_status_option = ''
  }

  if $disable_sflow {
    $disable_sflow_option = '--disable-sflow '
  } else {
    $disable_sflow_option = ''
  }

  $configure_options = "${gmetad_option}${disable_python_option}${enable_perl_option}${enable_status_option}${disable_sflow_option}--prefix=${core_src_dir} --sysconfdir=${config_dir}"
  $configure_command = "${core_src_dir}/configure ${configure_options}"

  # Passing false or undefined means no packages required!
  if $dep_packages {
    package{$dep_packages:
      ensure => 'installed',
    }
  }

  exec{'configure_core':
    cwd     => $core_src_dir,
    command => $configure_command,
    creates => "${core_src_dir}/config.status",
    require => [Package[$dep_packages], File[$core_src_dir]]
  }

  exec{'make_core':
    cwd     => $core_src_dir,
    command => 'make',
    require => Exec['configure_core'],
    creates => "${core_src_dir}/gmond/gmond",
  }

}
