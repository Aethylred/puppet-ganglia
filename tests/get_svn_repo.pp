include gcc
include rrd
class {'ck':
  provider => 'git',
  build    => true,
}
class{'ganglia':
  provider => 'svn',
  require  => Class['ck']
}
include ganglia::core::build
