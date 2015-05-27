# get the ganglia source from a repository
class ganglia::core::install::repo (
  $repo_uri     = undef,
  $provider     = 'svn',
  $core_src_dir = $ganglia::params::core_src_dir
) inherits ganglia::params {

  validate_re($provider,['git','svn'])
}
