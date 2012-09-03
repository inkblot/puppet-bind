class bind::params {

	case $::osfamily {
		'Debian': {
			$bind_package = 'bind9'
			$bind_service = 'bind9'
		}
		default: {
			fail("Operating system is not supported ${::osfamily}")
		}
	}

}
