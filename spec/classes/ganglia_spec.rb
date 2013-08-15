require 'spec_helper'

describe 'ganglia', :type => :class do
  context "on a Debian OS" do
    let :facts do
      {
        :osfamily               => 'Debian',
      }
    end
    it {should include_class('ganglia::params')}
  end
  context "on a RedHat OS" do
    let :facts do
      {
        :osfamily               => 'RedHat',
      }
    end
    it {should include_class('ganglia::params')}
  end
end