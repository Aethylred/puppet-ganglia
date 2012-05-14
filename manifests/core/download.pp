# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::core::download{

  include ganglia::parameters

  file{$ganglia::parameters::install_root:
    ensure => directory,
  }

  exec{'get_core':
    cwd     => $ganglia::parameters::src_root,
    path    => ['/usr/bin','/bin'],
    user    => root,
    command => "wget -O - ${ganglia::parameters::core_source_url}|tar xzv",
    creates => $ganglia::parameters::core_source_dir,
    require => File[$ganglia::parameters::install_root],
  }

  file{$ganglia::parameters::core_source_dir:
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Exec['get_core'],
  }

  file{$ganglia::parameters::core_dir:
    ensure  => link,
    path    => $ganglia::parameters::core_dir,
    target  => $ganglia::parameters::core_source_dir,
    require => File[$ganglia::parameters::core_source_dir]
  }
}