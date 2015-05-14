require 'spec_helper'

describe 'ganglia', :type => :class do
  let :pre_condition do
    'class rrd { $what = "a dummy class" }
     class rrd::cache { $what = "a dummy class"}'
  end

  $supported_os.each do | os_expects |
    os      = os_expects[:os]
    facts   = os_expects[:facts]
    expects = os_expects[:expects]
    context "on #{os}" do
      let (:facts) { facts }
      it { should contain_class('ganglia::params') }
      it { should_not contain_class('rrd') }
      it { should_not contain_package(expects[:rrd_lib_package]) }
      describe 'managing rrd libraries:' do
        describe 'manage_rrd => package' do
          let :params do
            { :manage_rrd => 'package'}
          end
          it {should_not contain_class('rrd')}
          it {should contain_package(expects[:rrd_lib_package])}
        end
        describe 'manage_rrd => module' do
          let :params do
            { :manage_rrd => 'module'}
          end
          it {should contain_class('rrd')}
          it {should_not contain_package(expects[:rrd_lib_package])}
        end
        describe 'manage_rrd => require' do
          let :params do
            { :manage_rrd => 'require'}
          end
          it {should contain_class('rrd')}
          it {should_not contain_package(expects[:rrd_lib_package])}
        end
      end
      describe 'managing rrd cache:' do
        describe 'manage_rrdcache => package' do
          let :params do
            { :manage_rrdcache => 'package'}
          end
          it {should_not contain_class('rrd::cache')}
          it {should contain_package(expects[:rrd_cache_package])}
        end
        describe 'manage_rrdcache => module' do
          let :params do
            { :manage_rrdcache => 'module'}
          end
          it {should contain_class('rrd::cache')}
          it {should_not contain_package(expects[:rrd_cache_package])}
        end
        describe 'manage_rrdcache => require' do
          let :params do
            { :manage_rrdcache => 'require'}
          end
          it {should contain_class('rrd::cache')}
          it {should_not contain_package(expects[:rrd_cache_package])}
        end
      end
    end
  end
end
