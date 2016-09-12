# == Class: novajoin::db::postgresql
#
# Class that configures postgresql for novajoin
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'novajoin'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'novajoin'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
# == Dependencies
#
# == Examples
#
# == Authors
#
# == Copyright
#
class novajoin::db::postgresql(
  $password,
  $dbname     = 'novajoin',
  $user       = 'novajoin',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  Class['novajoin::db::postgresql'] -> Service<| title == 'novajoin' |>

  ::openstacklib::db::postgresql { 'novajoin':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  ::Openstacklib::Db::Postgresql['novajoin'] ~> Exec<| title == 'novajoin-manage db_sync' |>

}
