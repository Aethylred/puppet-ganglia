# Class: ganglia::params
class ganglia::params{
  case $::osfamily{
    'Debian': {
      # revised variables
      $gmetad_packages = ['gmetad']
      $dep_packages    = [
        'libapr1-dev',
        'libconfuse-dev',
        'libexpat1-dev',
        'libpcre3-dev',
        'automake',
        'libtool'
      ]

      # old variables
      $web_package    = 'ganglia-webfrontend'
      $gmetad_package = 'gmetad'
      $gmond_package  = 'ganglia-monitor'
      $apache_user    = 'www-data'
      $web_root       = '/var/www'
    }
    'RedHat': {
      # revised variables
      $gmetad_packages = ['ganglia-gmetad']
      $dep_packages    = [
        'apr-devel',
        'libconfuse-devel',
        'expat-devel',
        'pcre-devel'
      ]

      # old variables
      $web_package    = 'ganglia-web'
      $gmetad_package = 'ganglia-gmetad'
      $gmond_package  = 'ganglia-gmond'
      $apache_user    = 'apache'
      $web_root       = '/var/www/html'
    }
    default:{
      fail("The OS Family ${::osfamily} is not supported in the ganglia module")
    }
  }

  # Revised paramters
  $core_src_dir   = '/usr/src/ganglia'
  $core_repo_ref  = 'release/3.7'
  $config_dir     = '/etc/ganglia'
  $build_prefix   = '/usr/local'
  $package_prefix = '/usr'

  # pre 1.0.0 parameters

  $metaserver_service     = 'gmetad'
  $monitor_service        = 'gmond'
  $metaserver_init        = "/etc/init.d/${metaserver_service}"
  $monitor_init           = "/etc/init.d/${monitor_service}"
  $metaserver_conf        = "${config_dir}/${metaserver_service}.conf"
  $monitor_conf           = "${config_dir}/${monitor_service}.conf"
  #$metaserver_bin         = "${prefix}/sbin/${metaserver_service}"
  #$monitor_bin            = "${prefix}/sbin/${monitor_service}"

# Set software versions
  $web_version        = '3.4.2'
  $core_version       = '3.7.1'
  $pyclient_version   = '3.3.0'

# Set software source URLs and files  
  $web_source_file    = "ganglia-web-${web_version}.tar.gz"
  $web_source_url     = "http://downloads.sourceforge.net/project/ganglia/ganglia-web/${web_version}/${web_source_file}"
  $web_dir            = '/usr/src/ganglia-web'
  $web_version_dir    = "${web_dir}-${web_version}"
  $web_site_dir       = "${web_root}/gangila2"

}
