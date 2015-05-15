# NeSI Ganglia metaserver install manifest
#
# Do NOT use directly use ganglia::metaserver or ganglia::client

class ganglia::core::install(
  $cluster_name   = 'mycluster',
  $cluster_url    = 'http://cluster.example.org',
  $data_sources   = ['localhost'],
  $latlong        = 'N0 W0',
  $owner          = 'Nobody',
  $grid_name      = false,
  $grid_authority = false,
  $with_gmetad    = false
){

  include ganglia::params
  include ganglia::core::download

  # This manifest installs from the Ganglia web site, so no packages please 
  package{$ganglia::params::metaserver_package: ensure => purged}
  package{$ganglia::params::monitor_package: ensure => purged}

  # Dependencies
  # NOTE: if we were using packages to install ganglia,
  # fewer packages would be required
  if $with_gmetad {
    case $::operatingsystem {
      Ubuntu: {
        package{'build-essential':  ensure => installed}
        package{'rrdtool':          ensure => installed}
        package{'libapr1-dev':      ensure => installed}
        package{'pkg-config':       ensure => installed}
        package{'libconfuse-dev':   ensure => installed}
        package{'libexpat1-dev':    ensure => installed}
        package{'libpcre3-dev':     ensure => installed}
        package{'librrd-dev':       ensure => installed}
      }
      CentOS: {
        package{'yum-plugin-downloadonly': ensure => installed}
        exec{'dev_tools':
          user    => 'root',
          path    => ['/usr/bin'],
          command => "yum -y groupinstall 'Development Tools'",
          unless  => "yum -y groupinstall 'Development Tools' --downloadonly",
          timeout => '0600',
          require => Package['yum-plugin-downloadonly'],
        }
        package{'apr-devel':        ensure => installed}
        package{'libconfuse-devel': ensure => installed}
        package{'expat-devel':      ensure => installed}
        package{'pcre-devel':       ensure => installed}
        package{'rrdtool-dev':      ensure => installed}
        package{'rrdtool':          ensure => installed}
      }
      default: {
        # Does nothing.
      }
    }
  } else {
    case $::operatingsystem {
      Ubuntu: {
        package{'build-essential':  ensure => installed}
        package{'pkg-config':       ensure => installed}
        package{'libapr1-dev':      ensure => installed}
        package{'libconfuse-dev':   ensure => installed}
        package{'libexpat1-dev':    ensure => installed}
        package{'libpcre3-dev':     ensure => installed}
      }
      CentOS: {
        package{'yum-plugin-downloadonly': ensure => installed}
        exec{'dev_tools':
          user    => 'root',
          path    => ['/usr/bin'],
          command => "yum -y groupinstall 'Development Tools'",
          unless  => '/usr/bin/yum grouplist "Development tools" | /bin/grep "^Installed Groups"',
          timeout => '0600',
          require => Package['yum-plugin-downloadonly'],
        }
        package{'apr-devel':        ensure => installed}
        package{'libconfuse-devel': ensure => installed}
        package{'expat-devel':      ensure => installed}
        package{'pcre-devel':       ensure => installed}
      }
      default: {
        # Does nothing.
      }
    }
  }

  if $with_gmetad {
    $configure_command = "${ganglia::params::src_dir}/configure --with-gmetad ${ganglia::params::configure_opts}"
    case $::osfamily {
      'Ubuntu': {
        $configure_require = [File[$ganglia::params::src_dir],Package['build-essential','libapr1-dev','pkg-config','libconfuse-dev','libexpat1-dev','libpcre3-dev','librrd-dev','rrdtool']]
      }
      'RedHat':{
        $configure_require = [File[$ganglia::params::src_dir],Exec['dev_tools'],Package['apr-devel','libconfuse-devel','expat-devel','pcre-devel','rrdtool-dev','rrdtool']]
      }
      default:{
        #does nothing
      }
    }
  } else {
    $configure_command = "${ganglia::params::src_dir}/configure ${ganglia::params::configure_opts}"
    case $::osfamily {
      'Ubuntu': {
        $configure_require = [File[$ganglia::params::src_dir],Package['build-essential','libapr1-dev','pkg-config','libconfuse-dev','libexpat1-dev','libpcre3-dev']]
      }
      'RedHat':{
        $configure_require = [File[$ganglia::params::src_dir],Exec['dev_tools'],Package['apr-devel','libconfuse-devel','expat-devel','pcre-devel']]
      }
      default:{
        #does nothing
      }
    }
  }

  user{'nobody': ensure => present}

  exec{'configure_core':
    cwd     => $ganglia::params::src_dir,
    user    => 'root',
    command => $configure_command,
    creates => "${ganglia::params::src_dir}/config.status",
    require => $configure_require,
  }

  exec{'make_core':
    cwd      => $ganglia::params::src_dir,
    user     => 'root',
    provider => 'shell',
    command  => 'make',
    require  => Exec['configure_core'],
    creates  => "${ganglia::params::src_dir}/gmond/gmond",
  }

  exec{'install_core':
    cwd      => $ganglia::params::src_dir,
    user     => 'root',
    provider => 'shell',
    command  => 'make install',
    require  => Exec['configure_core'],
    creates  => $ganglia::params::metaserver_bin,
  }

  if $with_gmetad {
    file{'metaserver_init':
      ensure  => 'file',
      path    => $ganglia::params::metaserver_init,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template("ganglia${ganglia::params::metaserver_init}.${::osfamily}.erb"),
      require => Exec['install_core'],
      notify  => Service[$ganglia::params::metaserver_service],
    }
    file{$ganglia::params::rrd_parentdir:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      require => Exec['install_core'],
    }

    file{$ganglia::params::rrd_rootdir:
      ensure  => 'directory',
      owner   => 'nobody',
      group   => 'root',
      require => [Exec['install_core'],File[$ganglia::params::rrd_parentdir]],
    }

    file{$ganglia::params::metaserver_conf:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      path    => $ganglia::params::metaserver_conf,
      content => template("ganglia${ganglia::params::metaserver_conf}.erb"),
      require => File[$ganglia::params::config_dir,$ganglia::params::rrd_parentdir,$ganglia::params::rrd_rootdir],
      notify  => Service[$ganglia::params::metaserver_service,'apache'],
    }

    service{$ganglia::params::metaserver_service:
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
    }
  } else {
    service{$ganglia::params::metaserver_service:
      ensure     => 'stopped',
      enable     => false,
      hasrestart => true,
      hasstatus  => false,
    }
  }

  file{$ganglia::params::config_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    require => Exec['install_core'],
  }

  file{$ganglia::params::monitor_conf:
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    path    => $ganglia::params::monitor_conf,
    content => template("ganglia${ganglia::params::monitor_conf}.erb"),
    require => File[$ganglia::params::config_dir],
    notify  => Service[$ganglia::params::monitor_service],
  }
  
  file{$ganglia::params::monitor_init:
    ensure  => 'file',
    path    => $ganglia::params::monitor_init,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template("ganglia${ganglia::params::monitor_init}.${::osfamily}.erb"),
    require => Exec['install_core'],
    notify  => Service[$ganglia::params::monitor_service],
  }

  service{$ganglia::params::monitor_service:
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    require    => File[$ganglia::params::monitor_init,$ganglia::params::monitor_conf],
  }

}
