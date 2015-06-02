# get the ganglia source from a repository
class ganglia::core::install::repo (
  $repo_uri     = undef,
  $repo_ref     = $ganglia::params::core_repo_ref,
  $provider     = 'git',
  $core_src_dir = $ganglia::params::core_src_dir,
) inherits ganglia::params {

  validate_re($provider,['git','svn'])

  if $repo_uri {
    $real_repo_uri = $repo_uri
  } else {
    $real_repo_uri = 'https://github.com/ganglia/monitor-core.git'
  }

  $clean_ref = regsubst($repo_ref, '\/', '-', 'G')
  $download_dir = "${core_src_dir}-${provider}-${clean_ref}"

  vcsrepo{$download_dir:
    ensure   => 'present',
    provider => $provider,
    source   => $real_repo_uri,
    revision => $repo_ref
  }

  file{'core_repo_download_dir':
    ensure  => 'directory',
    path    => $download_dir,
    require => Vcsrepo[$download_dir]
  }

  file{'ganglia_core_source_dir':
    ensure  => 'link',
    path    => $core_src_dir,
    target  => $download_dir,
    require => File['core_repo_download_dir']
  }
}
