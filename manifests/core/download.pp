# NeSI manifest to retireve and unpack the Ganglia Core archive

class ganglia::core::download(
  $install_path   = '/opt'
){

  include ganglia::parameters

  file{$install_path:
    ensure => directory,
  }

  exec{'get_core':
    cwd   => $install_path,
    path  => ['/usr/bin','/bin'],
    user  => root,
    command => "wget -O - ${ganglia::parameters::core_source_url}|tar xzv",
    require => File[$install_path],
  }
}