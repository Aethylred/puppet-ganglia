# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::core::download{

  include ganglia::parameters

  file{$ganglia::parameters::src_root:
    ensure => directory,
  }

  exec{'get_core':
    cwd     => $ganglia::parameters::src_root,
    path    => ['/usr/bin','/bin'],
    user    => root,
    command => "wget -O - ${ganglia::parameters::core_source_url}|tar xzv",
    creates => $ganglia::parameters::src_version_dir,
    require => File[$ganglia::parameters::src_root],
  }

  file{$ganglia::parameters::src_version_dir:
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Exec['get_core'],
  }

  file{$ganglia::parameters::src_dir:
    ensure  => link,
    path    => $ganglia::parameters::src_dir,
    target  => $ganglia::parameters::src_version_dir,
    require => File[$ganglia::parameters::src_version_dir]
  }
}