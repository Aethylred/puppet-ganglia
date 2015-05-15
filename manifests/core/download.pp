# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::core::download{

  include ganglia::params

  file{$ganglia::params::src_root:
    ensure => directory,
  }

  exec{'get_core':
    cwd     => $ganglia::params::src_root,
    path    => ['/usr/bin','/bin'],
    user    => root,
    command => "wget -O - ${ganglia::params::core_source_url}|tar xzv",
    creates => $ganglia::params::src_version_dir,
    require => File[$ganglia::params::src_root],
  }

  file{$ganglia::params::src_version_dir:
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Exec['get_core'],
  }

  file{$ganglia::params::src_dir:
    ensure  => link,
    path    => $ganglia::params::src_dir,
    target  => $ganglia::params::src_version_dir,
    require => File[$ganglia::params::src_version_dir]
  }
}
