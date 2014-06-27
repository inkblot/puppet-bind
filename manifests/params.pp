# ex: syntax=puppet si ts=4 sw=4 et

class bind::params {

    case $::osfamily {
        'Debian': {
            $bind_package = 'bind9'
            $bind_service = 'bind9'
            $confdir      = '/etc/bind'
            $cachedir     = '/var/cache/bind'
            $bind_user    = 'bind'
            $bind_group   = 'bind'
            $bind_rndc    = true

            $nsupdate_package = 'dnsutils'

            $bind_files = [
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
            ]
        }
        default: {
            fail("Operating system is not supported ${::osfamily}")
        }
    }

}
