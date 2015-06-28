include gcc
include rrd
class {'ck':
  provider => 'git',
  build    => true,
}
class{'ganglia':
  provider => 'git',
  require  => Class['ck']
}
include ganglia::core::build
