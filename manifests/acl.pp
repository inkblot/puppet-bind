# ex: syntax=puppet si ts=4 sw=4 et

define bind::acl (
    $addresses,
    $geoip_type = undef,
    $geoip_location = undef,
) {

    concat::fragment { "bind-acl-${name}":
        order   => '10',
        target  => "${bind::confdir}/acls.conf",
        content => template('bind/acl.erb'),
    }

}
