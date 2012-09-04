class bind::params {

	case $::osfamily {
		'Debian': {
			$bind_package = 'bind9'
			$bind_service = 'bind9'
			$confdir      = '/etc/bind'
			$cachedir     = '/var/cache/bind'
			$bind_user    = 'bind'
			$bind_group   = 'bind'

			file { [
				"${confdir}/bind.keys",
				"${confdir}/db.empty",
				"${confdir}/db.local",
				"${confdir}/db.root",
				"${confdir}/db.0",
				"${confdir}/db.127",
				"${confdir}/db.255",
				"${confdir}/named.conf.default-zones",
				"${confdir}/rndc.key",
				"${confdir}/zones.rfc1918",
				]:
				ensure  => present,
				require => Package[$bind_package],
			}
		}
		default: {
			fail("Operating system is not supported ${::osfamily}")
		}
	}

}
