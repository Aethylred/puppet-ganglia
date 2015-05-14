require 'spec_helper'

describe 'ganglia', :type => :class do
  let :pre_condition do
    'class rrd { $what = "a dummy class" }
     class rrd::cache { $what = "a dummy class"}'
  end
  context 'on a Debian OS' do
    let :facts do
      {
        :osfamily               => 'Debian',
      }
    end
    it {should contain_class('ganglia::params')}
    it {should_not contain_class('rrd')}
    it {should_not contain_package('librrd4')}
    describe 'managing rrd libraries:' do
      describe 'manage_rrd => package' do
        let :params do
          { :manage_rrd => 'package'}
        end
        it {should_not contain_class('rrd')}
        it {should contain_package('librrd4')}
      end
      describe 'manage_rrd => module' do
        let :params do
          { :manage_rrd => 'module'}
        end
        it {should contain_class('rrd')}
        it {should_not contain_package('librrd4')}
      end
      describe 'manage_rrd => require' do
        let :params do
          { :manage_rrd => 'require'}
        end
        it {should contain_class('rrd')}
        it {should_not contain_package('librrd4')}
      end
    end
    describe 'managing rrd cache:' do
      describe 'manage_rrdcache => package' do
        let :params do
          { :manage_rrdcache => 'package'}
        end
        it {should_not contain_class('rrd::cache')}
        it {should contain_package('rrdcached')}
      end
      describe 'manage_rrdcache => module' do
        let :params do
          { :manage_rrdcache => 'module'}
        end
        it {should contain_class('rrd::cache')}
        it {should_not contain_package('rrdcached')}
      end
      describe 'manage_rrdcache => require' do
        let :params do
          { :manage_rrdcache => 'require'}
        end
        it {should contain_class('rrd::cache')}
        it {should_not contain_package('rrdcached')}
      end
    end
  end
  context 'on a RedHat OS' do
    let :facts do
      {
        :osfamily               => 'RedHat',
      }
    end
    it {should contain_class('ganglia::params')}
    it {should_not contain_class('rrd')}
    it {should_not contain_package('rrdtool')}
    describe 'managing rrd libraries:' do
      describe 'manage_rrd => package' do
        let :params do
          { :manage_rrd => 'package'}
        end
        it {should_not contain_class('rrd')}
        it {should contain_package('rrdtool')}
      end
      describe 'manage_rrd => module' do
        let :params do
          { :manage_rrd => 'module'}
        end
        it {should contain_class('rrd')}
        it {should_not contain_package('rrdtool')}
      end
      describe 'manage_rrd => require' do
        let :params do
          { :manage_rrd => 'require'}
        end
        it {should contain_class('rrd')}
        it {should_not contain_package('rrdtool')}
      end
    end
    # Testing manage_rrdcache not required, idential to Debian case
  end
end
