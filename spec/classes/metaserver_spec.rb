require 'spec_helper'

describe 'ganglia::metaserver', :type => :class do
  let :pre_condition do
    'class rrd { $what = "a dummy class" }
     class rrd::cache { $what = "a dummy class"}'
  end

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    # expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      describe "with no parameters" do
        it{ should contain_class('ganglia::core::install').with(
          'cluster_name'   => 'MyCluster',
          'cluster_url'    => 'http://cluster.example.org',
          'latlong'        => '0,0',
          'owner'          => 'Nobody',
          'with_gmetad'    => true
        ) }
        it{ should contain_class('ganglia::core::install').with_data_sources( {
          "cluster_hosts"=>["localhost"],
          "cluster_name"=>"MyCluster"
        } ) }
        it{ should contain_class('ganglia::core::install').with_grid_name(false) }
        it{ should contain_class('ganglia::core::install').with_grid_authority(false) }
      end
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    it { should raise_error(Puppet::Error,
      %r{Ganglia metaserver not configured for Unknown}
    ) }
  end
end
