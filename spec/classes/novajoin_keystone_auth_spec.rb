#
# Unit tests for novajoin::keystone::auth
#

require 'spec_helper'

describe 'novajoin::keystone::auth' do
  shared_examples_for 'novajoin-keystone-auth' do
    context 'with default class parameters' do
      let :params do
        { :password => 'novajoin_password',
          :tenant   => 'foobar' }
      end

      it { is_expected.to contain_keystone_user('novajoin').with(
        :ensure   => 'present',
        :password => 'novajoin_password',
      ) }

      it { is_expected.to contain_keystone_user_role('novajoin@foobar').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )}

      it { is_expected.to contain_keystone_service('novajoin::FIXME').with(
        :ensure      => 'present',
        :description => 'novajoin FIXME Service'
      ) }

      it { is_expected.to contain_keystone_endpoint('RegionOne/novajoin::FIXME').with(
        :ensure       => 'present',
        :public_url   => 'http://127.0.0.1:FIXME',
        :admin_url    => 'http://127.0.0.1:FIXME',
        :internal_url => 'http://127.0.0.1:FIXME',
      ) }
    end

    context 'when overriding URL parameters' do
      let :params do
        { :password     => 'novajoin_password',
          :public_url   => 'https://10.10.10.10:80',
          :internal_url => 'http://10.10.10.11:81',
          :admin_url    => 'http://10.10.10.12:81', }
      end

      it { is_expected.to contain_keystone_endpoint('RegionOne/novajoin::FIXME').with(
        :ensure       => 'present',
        :public_url   => 'https://10.10.10.10:80',
        :internal_url => 'http://10.10.10.11:81',
        :admin_url    => 'http://10.10.10.12:81',
      ) }
    end

    context 'when overriding auth name' do
      let :params do
        { :password => 'foo',
          :auth_name => 'novajoiny' }
      end

      it { is_expected.to contain_keystone_user('novajoiny') }
      it { is_expected.to contain_keystone_user_role('novajoiny@services') }
      it { is_expected.to contain_keystone_service('novajoin::FIXME') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/novajoin::FIXME') }
    end

    context 'when overriding service name' do
      let :params do
        { :service_name => 'novajoin_service',
          :auth_name    => 'novajoin',
          :password     => 'novajoin_password' }
      end

      it { is_expected.to contain_keystone_user('novajoin') }
      it { is_expected.to contain_keystone_user_role('novajoin@services') }
      it { is_expected.to contain_keystone_service('novajoin_service::FIXME') }
      it { is_expected.to contain_keystone_endpoint('RegionOne/novajoin_service::FIXME') }
    end

    context 'when disabling user configuration' do

      let :params do
        {
          :password       => 'novajoin_password',
          :configure_user => false
        }
      end

      it { is_expected.not_to contain_keystone_user('novajoin') }
      it { is_expected.to contain_keystone_user_role('novajoin@services') }
      it { is_expected.to contain_keystone_service('novajoin::FIXME').with(
        :ensure      => 'present',
        :description => 'novajoin FIXME Service'
      ) }

    end

    context 'when disabling user and user role configuration' do

      let :params do
        {
          :password            => 'novajoin_password',
          :configure_user      => false,
          :configure_user_role => false
        }
      end

      it { is_expected.not_to contain_keystone_user('novajoin') }
      it { is_expected.not_to contain_keystone_user_role('novajoin@services') }
      it { is_expected.to contain_keystone_service('novajoin::FIXME').with(
        :ensure      => 'present',
        :description => 'novajoin FIXME Service'
      ) }

    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'novajoin-keystone-auth'
    end
  end
end
