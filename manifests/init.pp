# Class: ganglia
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
