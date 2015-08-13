include gcc
include rrd
class {'ck':
  provider => 'git',
  build    => true,
  before   => Class['ganglia']
}
class{'ganglia':
  provider => 'source',
  require  => Class['ck']
}
class{'ganglia::gmond':
  provider => 'source'
}
