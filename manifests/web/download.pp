# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::web::download{

  include ganglia::params

  exec{'get_web':
    cwd     => $ganglia::params::src_root,
    path    => ['/usr/bin','/bin'],
    user    => root,
    command => "wget -O - ${ganglia::params::web_source_url}|tar xzv",
    creates => $ganglia::params::web_version_dir,
    require => File[$ganglia::params::src_root],
  }

  file{$ganglia::params::web_version_dir:
    ensure  => directory,
    recurse => true,
    owner   => root,
    group   => root,
    require => Exec['get_web'],
  }

  file{$ganglia::params::web_dir:
    ensure  => link,
    path    => $ganglia::params::web_dir,
    target  => $ganglia::params::web_version_dir,
    require => File[$ganglia::params::web_version_dir]
  }
}
