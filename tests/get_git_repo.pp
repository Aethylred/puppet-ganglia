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
class{'ganglia::gmond':
  provider => 'git'
}
