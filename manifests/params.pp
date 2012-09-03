class bind::params {

	case $::osfamily {
		'Debian': {
			$bind_package = 'bind9'
			$bind_service = 'bind9'
			$confdir      = '/etc/bind'
			$bind_user    = 'bind'
			$bind_group   = 'bind'
		}
		default: {
			fail("Operating system is not supported ${::osfamily}")
		}
	}

}
