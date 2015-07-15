# installs the ganglia core software from source or git
class ganglia (
  $provider                = 'source',
  $core_version            = '3.7.1',
  $source_uri              = undef,
  $repo_uri                = undef,
  $repo_ref                = $ganglia::params::core_repo_ref,
  $prefix                  = undef,
  $core_src_dir            = $ganglia::params::core_src_dir,
  $config_dir              = $ganglia::params::config_dir,
  $with_gmetad             = false,
  $disable_python          = false,
  $enable_perl             = false,
  $enable_status           = false,
  $disable_sflow           = false,
  $dep_packages            = $ganglia::params::dep_packages,
  $rrdcached_address       = undef,
  $gmetad_ensure           = 'stopped',
  $gmetad_packages         = $ganglia::params::gmetad_packages,
  $gmetad_scalable         = false,
  $gmetad_gridname         = undef,
  $gmetad_authority        = undef,
  $gmetad_trusted_hosts    = undef,
  $gmetad_all_trusted      = false,
  $gmetad_setuid           = true,
  $gmetad_setuid_username  = undef,
  $gmetad_xml_port         = undef,
  $gmetad_interactive_port = undef,
  $gmetad_server_threads   = undef,
  $gmetad_rrd_rootdir      = undef,
  $gmetad_case_sensitive   = false
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
      if $config_dir != $ganglia::params::config_dir {
        fail('changing the config_dir is not recommended with the package provider')
      }
    }
    default:{
      fail('Unsupported provider, this should not happen')
    }
  }

  anchor{'post_core_install': }
  # class{ 'ganglia::core::install':
  #   require => Anchor['post_core_install']
  # }

  file{'ganglia_config_dir':
    ensure => 'directory',
    path   => $config_dir
  }

  class {'ganglia::gmetad':
    ensure            => $gmetad_ensure,
    provider          => $provider,
    packages          => $gmetad_packages,
    config_dir        => $config_dir,
    prefix            => $prefix,
    rrdcached_address => $rrdcached_address,
    scalable          => $gmetad_scalable,
    gridname          => $gmetad_gridname,
    authority         => $gmetad_authority,
    trusted_hosts     => $gmetad_trusted_hosts,
    all_trusted       => $gmetad_all_trusted,
    setuid            => $gmetad_setuid,
    setuid_username   => $gmetad_setuid_username,
    xml_port          => $gmetad_xml_port,
    interactive_port  => $gmetad_interactive_port,
    server_threads    => $gmetad_server_threads,
    rrd_rootdir       => $gmetad_rrd_rootdir,
    case_sensitive    => $gmetad_case_sensitive
  }

}
