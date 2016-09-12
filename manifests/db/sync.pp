#
# Class to execute novajoin-manage db_sync
#
# == Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the novajoin-dbsync command.
#   Defaults to undef
#
class novajoin::db::sync(
  $extra_params  = undef,
) {
  exec { 'novajoin-db-sync':
    command     => "novajoin-manage db_sync ${extra_params}",
    path        => '/usr/bin',
    user        => 'novajoin',
    refreshonly => true,
    subscribe   => [Package['novajoin'], Novajoin_config['database/connection']],
  }

  Exec['novajoin-manage db_sync'] ~> Service<| title == 'novajoin' |>
}
