# Class: ganglia
#
# This module sets up the ganglia environement
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
class ganglia (
  $manage_rrd       = undef,
  $manage_rrdcache  = undef,
) inherits ganglia::params {

  # Set up the round robin database, the options are to
  # - undefined or false: Do nothing, which relies on 
  #   the dependencies to be handled prior to calling
  #   the ganglia class, or automatically as part of 
  #   installing ganglia.
  # - module: the ganglia module will install rrd using
  #   the puppet-rrd module from https://github.com/nesi/puppet-rrd
  # - package: the ganglia module will install rrd using the
  #   packages distributed with the node's $::osfamily
  # - require: the ganglia module will require the rrd 
  #   module from https://github.com/nesi/puppet-rrd

  if $manage_rrd {
    case $manage_rrd {
      package:{
        package{$ganglia::params::rrd_lib_package:
          ensure => installed,
        }
      }
      module:{
        include rrd
      }
      require:{
        require rrd
      }
      default:{
        fail{"The value '${manage_rrd}' is not valid for the manage_rrd parameter for the ganglia class.": }
      }
    }
  }

  if $manage_rrdcache {
    case $manage_rrdcache {
      package:{
        package{$ganglia::params::rrd_cache_package:
          ensure => installed,
        }
      }
      module:{
        include rrd::cache
      }
      require:{
        require rrd::cache
      }
      default:{
        fail{"The value '${manage_rrd}' is not valid for the manage_rrd parameter for the ganglia class.": }
      }
    }
  }

}