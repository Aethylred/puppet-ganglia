# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::web::download{

  include ganglia::parameters

  exec{'get_web':
    cwd     => $ganglia::parameters::src_root,
    path    => ['/usr/bin','/bin'],
    user    => root,
    command => "wget -O - ${ganglia::parameters::web_source_url}|tar xzv",
    creates => $ganglia::parameters::web_version_dir,
    require => File[$ganglia::parameters::src_root],
  }

  file{$ganglia::parameters::web_version_dir:
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Exec['get_web'],
  }

  file{$ganglia::parameters::web_dir:
    ensure  => link,
    path    => $ganglia::parameters::web_dir,
    target  => $ganglia::parameters::web_version_dir,
    require => File[$ganglia::parameters::web_version_dir]
  }
}