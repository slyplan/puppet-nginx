define nginx::resource::upstream::member(
  $upstream,
  $ensure       = 'present',
  $weight       = undef,
  $max_fails    = undef,
  $fail_timeout = undef
) {

  if !defined(Nginx::Resource::Upstream[$upstream]) {
    fail "Undefined upstream $upstream"
  }

  $server_line   = "  server ${name}"
  $upstream_file = "${nginx::config::nx_conf_dir}/conf.d/${upstream}.conf"
  $server_ensure = $ensure ? {
    'absent' => absent,
    'down'   => 'present',
    default  => 'present',
  }

  if $ensure == 'down' {
    $server_line = "${server_line} down"
  }

  if $ensure == 'present' {
    if $weight != undef {
      $server_line = "${server_line} weight=${weight}"
    }
    if $max_fails != undef {
      $server_line = "${server_line} max_fails=${max_fails}"
    }
    if $fail_timeout != undef {
      $server_line = "${server_line} fail_timeout=${fail_timeout}"
    }
  }

  concat::fragment{ "upstream_${upstream}_${server}":
    target  => $upstream_file,
    content => "${server_line};\n",
    notify  => Class["nginx::service"]
  }

}