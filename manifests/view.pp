define bind::view (
	$match_clients      = 'any',
	$match_destinations = '',
	$zones              = [],
	$recursion          = true,
) {
	$confdir = $bind::params::confdir

	concat::fragment { "bind-view-${name}":
		order   => '10',
		target  => "${bind::params::confdir}/views.conf",
		content => template('bind/view.erb'),
	}
}
