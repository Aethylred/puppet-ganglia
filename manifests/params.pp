# Class: ganglia::params
#
# This module defines the global variables for the ganglia
# Puppet module
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

# This file is part of the ganglia Puppet module.
#
#     The ganglia Puppet module is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The ganglia Puppet module is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the ganglia Puppet module.  If not, see <http://www.gnu.org/licenses/>.

# [Remember: No empty lines between comments and class definition]
class ganglia::params{
  case $::osfamily{
    Debian: {
      # Revised variables
      $rrd_lib_package        = 'librrd4'
      $rrd_tool_package       = 'rrdtool'
      $rrd_cache_package      = 'rrdcached'
      # Unrevised variables
      $web_package            = 'ganglia-webfrontend'
      $metaserver_package     = 'gmetad'
      $monitor_package        = 'ganglia-monitor'
      $metaserver_service     = 'gmetad'
      $monitor_service        = 'gmond'
      $metaserver_init        = "/etc/init.d/${metaserver_service}"
      $monitor_init           = "/etc/init.d/${monitor_service}"
      $config_dir             = '/etc/ganglia'
      $metaserver_conf        = "${config_dir}/${metaserver_service}.conf"
      $monitor_conf           = "${config_dir}/${monitor_service}.conf"
      $rrd_parentdir          = '/var/lib/ganglia'
      $rrd_rootdir            = '/var/lib/ganglia/rrds'
      $prefix                 = '/usr'
      $metaserver_bin         = "${prefix}/sbin/${metaserver_service}"
      $monitor_bin            = "${prefix}/sbin/${monitor_service}"
      $apache_user            = 'www-data'
      $web_root               = '/var/www'
    }
    RedHat: {
      # Revised variables
      $rrd_lib_package        = 'rrdtool'
      $rrd_tool_package       = 'rrdtool'
      $rrd_cache_package      = 'rrdcached'
      # Unrevised variables
      $web_package            = 'ganglia-web'
      $metaserver_package     = 'ganglia-gmetad'
      $monitor_package        = 'ganglia-gmond'
      $metaserver_service     = 'gmetad'
      $monitor_service        = 'gmond'
      $metaserver_init        = "/etc/init.d/${metaserver_service}"
      $monitor_init           = "/etc/init.d/${monitor_service}"
      $config_dir             = '/etc/ganglia'
      $metaserver_conf        = "${config_dir}/${metaserver_service}.conf"
      $monitor_conf           = "${config_dir}/${monitor_service}.conf"
      $rrd_parentdir          = '/var/lib/ganglia'
      $rrd_rootdir            = '/var/lib/ganglia/rrds'
      $prefix                 = '/usr'
      $metaserver_bin         = "${prefix}/sbin/${metaserver_service}"
      $monitor_bin            = "${prefix}/sbin/${monitor_service}"
      $apache_user            = 'apache'
      $web_root               = '/var/www/html'
    }
    default:{
      fail{"The OS Family '${::osfamily}' is not supported in the ganglia module!": }
    }
  }

# Installation parameters
  $src_root       = '/src'

# configure options
  $configure_opts     = "--prefix=${prefix} --sysconfdir=${config_dir}"


# Set software versions
  $web_version        = '3.4.2'
  $core_version       = '3.3.7'
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