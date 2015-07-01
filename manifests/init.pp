# installs the ganglia core software from source or git
class ganglia (
  $provider       = 'source',
  $core_version   = '3.7.1',
  $source_uri     = undef,
  $repo_uri       = undef,
  $repo_ref       = $ganglia::params::core_repo_ref,
  $prefix         = undef,
  $core_src_dir   = $ganglia::params::core_src_dir,
  $config_dir     = $ganglia::params::config_dir,
  $with_gmetad    = false,
  $disable_python = false,
  $enable_perl    = false,
  $enable_status  = false,
  $disable_sflow  = false,
  $dep_packages   = $ganglia::params::dep_packages,
) inherits ganglia::params {

  validate_re($provider,['package','source','git','svn'])

  case $provider {
    'source': {
      class{ 'ganglia::core::install::source':
        source_uri   => $source_uri,
        core_src_dir => $core_src_dir,
        core_version => $core_version,
        before       => Anchor['post_core_install']
      }
      class{ 'ganglia::core::build':
        core_src_dir   => $core_src_dir,
        with_gmetad    => $with_gmetad,
        disable_python => $disable_python,
        enable_perl    => $enable_perl,
        enable_status  => $enable_status,
        disable_sflow  => $disable_sflow,
        prefix         => $prefix,
        dep_packages   => $dep_packages,
        config_dir     => $config_dir
      }
    }
    'git','svn': {
      class{ 'ganglia::core::install::repo':
        repo_uri     => $repo_uri,
        repo_ref     => $repo_ref,
        provider     => $provider,
        core_src_dir => $core_src_dir,
        before       => Anchor['post_core_install']
      }
      class{ 'ganglia::core::build':
        core_src_dir   => $core_src_dir,
        with_gmetad    => $with_gmetad,
        disable_python => $disable_python,
        enable_perl    => $enable_perl,
        enable_status  => $enable_status,
        disable_sflow  => $disable_sflow,
        prefix         => $prefix,
        dep_packages   => $dep_packages,
        config_dir     => $config_dir
      }
    }
    'package':{
      # Packages are installed by component, not via the base class
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
