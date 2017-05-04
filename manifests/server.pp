# ex: syntax=puppet si ts=4 sw=4 et

define bind::server (
    $bogus     = false,
    $edns      = true,
    $key       = undef,
    $transfers = undef,
) {
    include ::bind

    concat::fragment { "bind-server-${name}":
        order   => 10,
        target  => "${::bind::confdir}/servers.conf",
        content => template('bind/server.erb'),
    }
}
