require 'spec_helper'

describe 'novajoin::db' do

  shared_examples 'novajoin::db' do
    context 'with default parameters' do
      it { is_expected.to contain_novajoin_config('database/connection').with_value('sqlite:////var/lib/novajoin/novajoin.sqlite') }
      it { is_expected.to contain_novajoin_config('database/idle_timeout').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_novajoin_config('database/min_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_novajoin_config('database/max_retries').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_novajoin_config('database/retry_interval').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_novajoin_config('database/max_pool_size').with_value('<SERVICE DEFAULT>') }
      it { is_expected.to contain_novajoin_config('database/max_overflow').with_value('<SERVICE DEFAULT>') }
    end

    context 'with specific parameters' do
      let :params do
        { :database_connection     => 'mysql+pymysql://novajoin:novajoin@localhost/novajoin',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_max_pool_size  => '11',
          :database_max_overflow   => '21',
        }
      end

      it { is_expected.to contain_novajoin_config('database/connection').with_value('mysql+pymysql://novajoin:novajoin@localhost/novajoin') }
      it { is_expected.to contain_novajoin_config('database/idle_timeout').with_value('3601') }
      it { is_expected.to contain_novajoin_config('database/min_pool_size').with_value('2') }
      it { is_expected.to contain_novajoin_config('database/max_retries').with_value('11') }
      it { is_expected.to contain_novajoin_config('database/retry_interval').with_value('11') }
      it { is_expected.to contain_novajoin_config('database/max_pool_size').with_value('11') }
      it { is_expected.to contain_novajoin_config('database/max_overflow').with_value('21') }
    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection     => 'postgresql://novajoin:novajoin@localhost/novajoin', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection     => 'mysql://novajoin:novajoin@localhost/novajoin', }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection     => 'foodb://novajoin:novajoin@localhost/novajoin', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection     => 'foo+pymysql://novajoin:novajoin@localhost/novajoin', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

  end

  shared_examples_for 'novajoin::db on Debian' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://novajoin:novajoin@localhost/novajoin', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('db_backend_package').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack'
        )
      end
    end
  end

  shared_examples_for 'novajoin::db on RedHat' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection     => 'mysql+pymysql://novajoin:novajoin@localhost/novajoin', }
      end

      it 'install the proper backend package' do
        is_expected.not_to contain_package('db_backend_package')
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_configures 'novajoin::db'
      it_configures "novajoin::db on #{facts[:osfamily]}"
    end
  end
end
