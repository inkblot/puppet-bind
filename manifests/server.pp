# ex: syntax=puppet si ts=4 sw=4 et

define bind::server (
    $bogus     = false,
    $edns      = true,
    $key       = undef,
    $transfers = undef,
    $order     = '10',
) {
    include bind

    concat::fragment { "bind-server-${name}":
        order   => $order,
        target  => "${::bind::confdir}/servers.conf",
        content => template('bind/server.erb'),
    }
}
