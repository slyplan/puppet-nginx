# define: nginx::resource::upstream
#
# This definition creates a new upstream proxy entry for NGINX
#
# Parameters:
#   [*members*]               - Array of member URIs for NGINX to connect to. Must follow valid NGINX syntax.
#   [*ensure*]                - Enables or disables the specified location (present|absent)
#   [*upstream_cfg_prepend*] - It expects a hash with custom directives to put before anything else inside upstream
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::upstream { 'proxypass':
#    ensure  => present,
#    members => [
#      "localhost:3000",
#      "localhost:3001",
#      "localhost:3002",
#    ],
#  }
#
#  Custom config example to use ip_hash, and 20 keepalive connections
#  create a hash with any extra custom config you want.
#  $my_config = {
#    'ip_hash'   => '',
#    'keepalive' => '20',
#  }
#  nginx::resource::upstream { 'proxypass':
#    ensure              => present,
#    members => [
#      "localhost:3000",
#      "localhost:3001",
#      "localhost:3002",
#    ],
#    upstream_cfg_prepend => $my_config,
#  }
define nginx::resource::upstream (
  $members = [],
  $ensure = 'present',
  $upstream_cfg_prepend = {}) {

  include concat::setup

  # $upstream_path = "/etc/nginx/conf.d/${name}"
  $upstream_file = "/etc/nginx/conf.d/${name}-upstream.conf"

  concat { $upstream_file:
    owner => 'root',
    group => 'root',
    mode  => '0644',
    notify => Class["nginx::service"]
  }

  concat::fragment{ "upstream_${name}_header":
    target  => $upstream_file,
    content => "upstream ${name} {\n",
    order   => '001'
  }

  $upstream_cfg = join(join_keys_to_values($upstream_cfg_prepend, " "), ";\n")

  concat::fragment{ "upstream_${name}_cfg":
    target  => $upstream_file,
    content => "${upstream_cfg} \n",
    order   => '002'
  } 

  concat::fragment{ "upstream_${name}_footer":
    target  => $upstream_file,
    content => "\n }",
    order   => '999'
  } 

  $members_with_upstream = prefix($members, "${name}:")
  if size($members) > 0 {
    nginx::resource::str2member{ $members_with_upstream: } 
  }

  Nginx::Resource::Member <<| tag == $name |>>

}
