# == Class: novajoin::config
#
# This class is used to manage arbitrary novajoin configurations.
#
# === Parameters
#
# [*novajoin_config*]
#   (optional) Allow configuration of arbitrary novajoin configurations.
#   The value is an hash of novajoin_config resources. Example:
#   { 'DEFAULT/foo' => { value => 'fooValue'},
#     'DEFAULT/bar' => { value => 'barValue'}
#   }
#   In yaml format, Example:
#   novajoin_config:
#     DEFAULT/foo:
#       value: fooValue
#     DEFAULT/bar:
#       value: barValue
#
#   NOTE: The configuration MUST NOT be already handled by this module
#   or Puppet catalog compilation will fail with duplicate resources.
#
class novajoin::config (
  $novajoin_config = {},
) {

  validate_hash($novajoin_config)

  create_resources('novajoin_config', $novajoin_config)
}
