# == Class: novajoin::policy
#
# Configure the novajoin policies
#
# === Parameters
#
# [*policies*]
#   (optional) Set of policies to configure for novajoin
#   Example :
#     {
#       'novajoin-context_is_admin' => {
#         'key' => 'context_is_admin',
#         'value' => 'true'
#       },
#       'novajoin-default' => {
#         'key' => 'default',
#         'value' => 'rule:admin_or_owner'
#       }
#     }
#   Defaults to empty hash.
#
# [*policy_path*]
#   (optional) Path to the nova policy.json file
#   Defaults to /etc/novajoin/policy.json
#
class novajoin::policy (
  $policies    = {},
  $policy_path = '/etc/novajoin/policy.json',
) {

  validate_hash($policies)

  Openstacklib::Policy::Base {
    file_path => $policy_path,
  }

  create_resources('openstacklib::policy::base', $policies)

  oslo::policy { 'novajoin_config': policy_file => $policy_path }

}
