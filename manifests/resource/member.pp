define nginx::resource::member(
  $upstream,
  $host,
  $port,
  $ensure = 'present'
) {

  # $upstream_path = "/etc/nginx/conf.d/${upstream}"
  $upstream_file = "/etc/nginx/conf.d/${upstream}-upstream.conf"

  if !defined(Nginx::Resource::Upstream[$upstream]) {
    fail "Undefined upstream $upstream"
  }

  concat::fragment{ "upstream_${upstream}_server_${host}_${port}":
    target  => $upstream_file,
    content => "  server ${host}:${port};\n",
    notify  => Class["nginx::service"]
  }

}