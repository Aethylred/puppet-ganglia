require 'spec_helper'

describe 'ganglia::web', :type => :class do

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    # expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      describe "with no parameters" do
        it{ should contain_class('ganglia::web::install').with(
          'site_admin' => 'admin@example.org'
        ) }
      end
    end
  end
  context "on and Unknown operating system" do
    let (:facts) do
      { :osfamily => 'Unknown' }
    end
    it { should raise_error(Puppet::Error,
      %r{Ganglia web interface is not configured for Unknown}
    ) }
  end
end
