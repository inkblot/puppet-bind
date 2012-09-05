define bind::zone (
	$zone_type,
	$domain          = '',
	$masters         = [],
	$allow_updates   = [],
	$allow_transfers = [],
) {
	if $domain == '' {
		$_domain = $name
	} else {
		$_domain = $domain
	}

	$file = "${bind::confdir}/zones/${name}.zone"

	file { "${bind::confdir}/zones/${name}.conf":
		ensure  => present,
		owner   => 'root',
		group   => $bind::params::bind_group,
		mode    => '0644',
		content => template('bind/zone.conf.erb'),
		notify  => Service[$bind::params::bind_server],
	}

}
