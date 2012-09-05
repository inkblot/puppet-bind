define bind::key (
	$algorithm => 'hmac-sha256',
	$secret,
) {
	file { "${bind::confdir}/keys/${name}.conf":
		ensure  => present,
		owner   => 'root',
		group   => $bind::params::bind_group,
		mode    => '0640',
		content => template('bind/key.conf.erb'),
		notify  => Service[$bind::params::bind_service],
	}
	concat::fragment { "bind-key-${name}":
		order   => '10',
		target  => "${bind::confdir}/named.conf",
		content => "include \"${bind::confdir}/keys/${name}.conf\";\n",
	}
}
