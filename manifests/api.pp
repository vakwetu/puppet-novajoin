# == Class: novajoin::api
#
# The novajoin::api class encapsulates a IPA Nova Join API service.
#
# === Parameters
#
# [*enabled*]
#   (optional) Whether to enable services.
#   Defaults to true.
#
# [*ensure_package*]
#   (optional) The state of novajoin packages.
#   Defaults to 'present'
#
# [*hostname*]
#   (optional) The machine's fully qualified host name.
#   Default to '${::fqdn}'.
#
# [*ipa_password*]
#   (optional) Password for the IPA principal.
#   TODO(alee): make this optional if keytab already present.
#   Defaults to undef
#
# [*ipa_password_file*]
#   (optional) Path to file containing IPA principal password.
#   Defaults to undef
#
# [*ipa_principal*]
#   (required) Principal to set up IPA integration.
#
# [*keystone_auth_uri*]
#   (optional) auth_uri for keystone instance.
#   Defaults to undef
#
# [*keystone_auth_url*]
#   (optional) auth_url for the keystone instance.
#   Defaults to undef
#
# [*keystone_identity_uri*]
#   (optional) identity_uri for the keystone instance.
#   Defaults to undef
#
# [*manage_service*]
#   (optional) If Puppet should manage service startup / shutdown.
#   Defaults to true.
#
# [*nova_password*]
#   (required) Password for the nova service user.
#   Defaults to undef
#
# [*nova_user*]
#   (optional) User that nova services run as.
#   Defaults to 'nova'
#
class novajoin::api (
  $enabled               = true,
  $ensure_package        = 'present',
  $hostname              = "${::fqdn}",
  $ipa_password          = undef,
  $ipa_password_file     = undef,
  $ipa_principal         = undef,
  $keystone_auth_uri     = undef,
  $keystone_auth_url     = undef,
  $keystone_identity_uri = undef,
  $manage_service        = true,
  $nova_password         = undef,
  $nova_user             = 'nova',
) inherits novajoin::params {

  require ::ipa::client

  if $ipa_principal == undef {
    fail('ipa_principal is required to be set')
  }

  if $nova_password == undef {
    fail('nova_password is required to be set.')
  }

  $opt1 = "--hostname ${hostname} --principal ${ipa_principal} --user ${nova_user} --nova-password ${nova_password}"
  
  if $ipa_password_file != undef {
    $opt2 = "--password_file ${ipa_password_file}"
  }
  elsif $ipa_password != undef {
    $opt2 = "--password ${ipa_password}"
  }
  else {
    fail('either ipa_password or ipa_password_file must be set')
  }


  if $keystone_auth_url != undef {
    $opt3 = "--keystone_auth_url ${keystone_auth_url}"
  }

  if $keystone_auth_uri != undef {
    $opt4 = "--keystone_auth_uri ${keystone_auth_uri}"
  }

  if $keystone_identity_uri != undef {
    $opt5 = " --keystone_identity ${keystone_identity_uri}"
  }

  $install_opts = "${opt1} ${opt2} ${opt3} ${opt4} ${opt5}"

  package { 'python-novajoin':
    ensure => $ensure_package,
    name   => $::novajoin::params::package_name,
    tag    => ['openstack', 'novajoin-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'novajoin-api':
    ensure     => $service_ensure,
    name       => $::novajoin::params::service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => 'novajoin-service',
  }

  exec { 'novajoin-install-script':
    command  => "/usr/sbin/novajoin-install ${install_opts}",
    require  => Package['python-novajoin']
  }

  Package['python-novajoin'] -> Exec['novajoin-install-script'] ~> Service['novajoin-api']
  Exec['novajoin-install-script'] ~> Service['nova-api']
}
