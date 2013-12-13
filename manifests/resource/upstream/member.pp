define nginx::resource::upstream::member(
  $upstream,
  $ensure       = 'present',
  $member_cfg   = undef
) {

  if !defined(Nginx::Resource::Upstream[$upstream]) {
    fail "Undefined upstream $upstream"
  }

  $upstream_file = "${nginx::config::nx_conf_dir}/conf.d/${upstream}.conf"
  $server_ensure = $ensure ? {
    'absent' => absent,
    'down'   => 'present',
    default  => 'present',
  }

  if $ensure == 'down' {
    $server_postfix = " down"
  } elsif $ensure == 'present' {
    if $member_cfg != undef {
      $server_postfix = inline_template("<% @member_cfg.each do |key,value| %><%= key %>=<%= value %> <% end -%>")
    }
  }

  concat::fragment{ "upstream_${upstream}_${name}":
    target  => $upstream_file,
    content => "  server ${name} ${server_postfix};\n",
    notify  => Class["nginx::service"]
  }

}