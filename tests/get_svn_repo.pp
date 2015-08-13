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
class{'ganglia::gmond':
  provider => 'svn'
}
