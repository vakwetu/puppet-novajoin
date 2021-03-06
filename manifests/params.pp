# Parameters for puppet-novajoin
#
class novajoin::params {
  include ::openstacklib::defaults

  case $::osfamily {
    'RedHat': {
      $package_name        = 'python-novajoin'
      $service_name        = 'novajoin-server'
      $notify_service_name = 'novajoin-notify'
    }
    'Debian': {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem")
    }
  } # Case $::osfamily
}
