# get the ganglia source tarballs
class ganglia::core::install::source (
  $source_uri   = undef,
  $core_version = $ganglia::params::core_version,
  $core_src_dir = $ganglia::params::core_src_dir
) inherits ganglia::params {

  $download_dir = "${core_src_dir}-${core_version}"

  if $source_uri {
    $real_source_uri = $source_uri
  } else {
    $real_source_uri = "http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/${core_version}/ganglia-${core_version}.tar.gz"
  }

  file{'core_source_download_dir':
    ensure => 'directory',
    path   => $download_dir
  }

  exec{'get_core_source_tarball':
    path    => ['/usr/bin','/bin'],
    command => "wget -O - ${real_source_uri}|tar xzv -C ${download_dir} --strip-components=1",
    creates => "${download_dir}/README",
    require => File['core_source_download_dir']
  }

  file{'ganglia_core_source_dir':
    ensure => 'link',
    path   => $core_src_dir,
    target => $download_dir
  }

}
