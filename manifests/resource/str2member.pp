define nginx::resource::str2member($member_string = $name) {

  $member_array = split($member_string, ':')
  if size($member_array) != 3 {
    fail "Can't convert string '${member_string}' to member. String must be a 'upstream:host:port'"
  }

  nginx::resource::member { "/etc/nginx/conf.d/${member_array[0]}/${member_array[1]}-${member_array[2]}.conf":
    upstream => $member_array[0],
    host     => $member_array[1],
    port     => $member_array[2],
  }

}