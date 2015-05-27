# installs the ganglia core software from source or git
class ganglia (
  $provider      = 'source',
  $core_version  = '3.7.1',
  $source_uri    = undef,
  $repo_uri      = undef,
  $core_src_dir  = $ganglia::params::core_src_dir
) inherits ganglia::params {

  validate_re($provider,['package','source','git','svn'])

  case $provider {
    'source': {
      class{ 'ganglia::core::install::source':
        source_uri   => $source_uri,
        core_version => $core_version,
        core_src_dir => $core_src_dir,
        before       => Anchor['post_core_install']
      }
    }
    'git','svn': {
      class{ 'ganglia::core::install::repo':
        repo_uri     => $repo_uri,
        provider     => $provider,
        core_src_dir => $core_src_dir,
        before       => Anchor['post_core_install']
      }
    }
    'package':{
      fail('Packages are installed by component, not via the core installer')
    }
    default:{
      fail('Unsupported provider, this should not happen')
    }
  }

  anchor{'post_core_install': }
  # class{ 'ganglia::core::install':
  #   require => Anchor['post_core_install']
  # }

}
