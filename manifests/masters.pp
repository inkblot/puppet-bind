# ex: syntax=puppet si ts=4 sw=4 et

define bind::masters (
    $addresses,
) {

    concat::fragment { "bind-masters-${name}":
        order   => '10',
        target  => "${bind::confdir}/masters.conf",
        content => template('bind/masters.erb'),
    }

}
