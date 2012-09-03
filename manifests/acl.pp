define bind::acl (
	$addresses,
) {

	concat::fragment { "bind-acl-${name}":
		order   => '10',
		target  => "${bind::params::confdir}/acls.conf",
		content => template('bind/acl.erb'),
	}

}
