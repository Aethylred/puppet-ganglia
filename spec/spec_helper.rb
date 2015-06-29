require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|

  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end

$supported_os = on_supported_os.map do |os, facts|
  os_expects = {}
  expects = {
    :src_root           => '/src',
    :web_version        => '3.4.2',
    :core_version       => '3.7.1',
    :pyclient_version   => '3.3.0' ,
    :metaserver_service => 'gmetad',
    :monitor_service    => 'gmond',
    :metaserver_init    => '/etc/init.d/gmetad',
    :monitor_init       => '/etc/init.d/gmond',
    :metaserver_conf    => '/etc/ganglia/gmetad.conf',
    :monitor_conf       => '/etc/ganglia/gmond.conf',
    :prefix             => '/usr',
    :metaserver_bin     => '/usr/sbin/gmetad',
    :monitor_bin        => '/usr/sbin/gmond',
    :config_dir         => '/etc/ganglia',
    :core_source_file   => 'ganglia-3.7.1.tar.gz',
    :core_source_url    => 'http://downloads.sourceforge.net/project/ganglia/ganglia%20monitoring%20core/3.7.1/ganglia-3.7.1.tar.gz',
    :src_dir            => '/src/ganglia',
    :src_version_dir    => '/src/ganglia-3.7.1',
    :web_source_file    => 'ganglia-web-3.4.2.tar.gz',
    :web_source_url     => 'http://downloads.sourceforge.net/project/ganglia/ganglia-web/3.4.2/ganglia-web-3.4.2.tar.gz',
    :web_dir            => '/src/ganglia-web',
    :web_version_dir    => '/src/ganglia-web-3.4.2',
    :configure_opts     => "--prefix=/usr --sysconfdir=/etc/ganglia"
  }
  case facts[:osfamily]
  when 'Debian'
    expects.merge!( {
      :web_package        => 'ganglia-webfrontend',
      :metaserver_package => 'gmetad',
      :monitor_package    => 'ganglia-monitor',
      :apache_user        => 'www-data',
      :web_root           => '/var/www',
      :web_site_dir       => '/var/www/gangila2',
      :dep_packages       => [
        'libapr1-dev',
        'libconfuse-dev',
        'libexpat1-dev',
        'libpcre3-dev',
        'automake',
        'libtool'
      ],
      :base_packages      => [
        'build-essential',
        'libapr1-dev',
        'pkg-config',
        'libconfuse-dev',
        'libexpat1-dev',
        'libpcre3-dev',
      ],
      :gmetad_package     => 'gmetad',
      :gmond_package      => 'ganglia-monitor',
      :configure_require  => [
        'File[/src/ganglia]',
        'Package[build-essential]',
        'Package[libapr1-dev]',
        'Package[pkg-config]',
        'Package[libconfuse-dev]',
        'Package[libexpat1-dev]',
        'Package[libpcre3-dev]'
      ],
      :gmetad_config_req => [
        'File[/src/ganglia]',
        'Package[build-essential]',
        'Package[libapr1-dev]',
        'Package[pkg-config]',
        'Package[libconfuse-dev]',
        'Package[libexpat1-dev]',
        'Package[libpcre3-dev]',
      ]
    } )
  when 'RedHat'
    expects.merge!( {
      :web_package        => 'ganglia-web',
      :metaserver_package => 'ganglia-gmetad',
      :monitor_package    => 'ganglia-gmond',
      :apache_user        => 'apache',
      :web_root           => '/var/www/html',
      :web_site_dir       => '/var/www/html/gangila2',
      :dep_packages       => [
        'apr-devel',
        'libconfuse-devel',
        'expat-devel',
        'pcre-devel'
      ],
      :base_packages           => [
        'yum-plugin-downloadonly',
        'apr-devel',
        'libconfuse-devel',
        'expat-devel',
        'pcre-devel'
      ],
      :gmetad_package     => 'ganglia-gmetad',
      :gmond_package      => 'ganglia-gmond',
      :configure_require => [
        'File[/src/ganglia]',
        'Exec[dev_tools]',
        'Package[apr-devel]',
        'Package[libconfuse-devel]',
        'Package[expat-devel]',
        'Package[pcre-devel]',
      ],
      :gmetad_config_req => [
        'File[/src/ganglia]',
        'Exec[dev_tools]',
        'Package[apr-devel]',
        'Package[libconfuse-devel]',
        'Package[expat-devel]',
        'Package[pcre-devel]',
      ]
    } )
  end

  os_expects = {
    :os      => os,
    :facts   => facts,
    :expects => expects
  }
  os_expects
end
