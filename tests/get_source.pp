include gcc
include rrd
class {'ck':
  provider => 'git',
  build    => true,
  before   => Class['ganglia']
}
include ganglia
include ganglia::core::build
