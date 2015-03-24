# ex: syntax=puppet si ts=4 sw=4 et

class bind::params (
    $supported,
    $bind_user,
    $bind_group,
    $bind_package,
    $bind_service,
    $nsupdate_package,
) {
    unless $supported {
        fail('Platform is not supported')
    }

    if $::osfamily == 'Debian' {
        $bind_files = [
            "${::bind::confdir}/bind.keys",
            "${::bind::confdir}/db.empty",
            "${::bind::confdir}/db.local",
            "${::bind::confdir}/db.root",
            "${::bind::confdir}/db.0",
            "${::bind::confdir}/db.127",
            "${::bind::confdir}/db.255",
            "${::bind::confdir}/named.conf.default-zones",
            "${::bind::confdir}/zones.rfc1918",
        ]
    }
    elsif $::osfamily == 'RedHat' {
        $bind_files = ['/etc/named.root.key']
    }
}
