# Class: ganglia::params
class ganglia::params{
  case $::osfamily{
    'Debian': {
      $web_package    = 'ganglia-webfrontend'
      $gmetad_package = 'gmetad'
      $gmond_package  = 'ganglia-monitor'
      $apache_user    = 'www-data'
      $web_root       = '/var/www'
      $dep_packages   = [
        'libapr1-dev',
        'libconfuse-dev',
        'libexpat1-dev',
        'libpcre3-dev',
        'libck-dev'
      ]
    }
    'RedHat': {
      $web_package    = 'ganglia-web'
      $gmetad_package = 'ganglia-gmetad'
      $gmond_package  = 'ganglia-gmond'
      $apache_user    = 'apache'
      $web_root       = '/var/www/html'
      $dep_packages   = [
        'apr-devel',
        'libconfuse-devel',
        'expat-devel',
        'pcre-devel'
      ]
    }
    default:{
      fail("The OS Family ${::osfamily} is not supported in the ganglia module")
    }
  }

  # Revised paramters
  $core_src_dir   = '/usr/src/ganglia'
  $core_repo_ref  = 'release/3.7'
  $config_dir     = '/etc/ganglia'


  # pre 1.0.0 parameters

  $metaserver_service     = 'gmetad'
  $monitor_service        = 'gmond'
  $metaserver_init        = "/etc/init.d/${metaserver_service}"
  $monitor_init           = "/etc/init.d/${monitor_service}"
  $metaserver_conf        = "${config_dir}/${metaserver_service}.conf"
  $monitor_conf           = "${config_dir}/${monitor_service}.conf"
  $metaserver_bin         = "${prefix}/sbin/${metaserver_service}"
  $monitor_bin            = "${prefix}/sbin/${monitor_service}"

# Installation parameters
  $src_root       = '/src'
  $prefix         = '/usr'

# configure options
  $configure_opts     = "--prefix=${prefix} --sysconfdir=${config_dir}"


# Set software versions
  $web_version        = '3.4.2'
  $core_version       = '3.7.1'
  $pyclient_version   = '3.3.0'

# Set software source URLs and files  
  $core_source_file   = "ganglia-${core_version}.tar.gz"
  $core_source_url    = "http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/${core_version}/${core_source_file}"
  $src_dir            = "${src_root}/ganglia"
  $src_version_dir    = "${src_dir}-${core_version}"

  $web_source_file    = "ganglia-web-${web_version}.tar.gz"
  $web_source_url     = "http://downloads.sourceforge.net/project/ganglia/ganglia-web/${web_version}/${web_source_file}"
  $web_dir            = "${src_root}/ganglia-web"
  $web_version_dir    = "${web_dir}-${web_version}"
  $web_site_dir       = "${web_root}/gangila2"

}
