# ex: syntax=puppet si ts=4 sw=4 et

define bind::view (
    $match_clients                = 'any',
    $match_destinations           = '',
    $zones                        = [],
    $recursion                    = true,
    $recursion_match_clients      = 'any',
    $recursion_match_destinations = '',
) {
    $confdir = $::bind::confdir

    concat::fragment { "bind-view-${name}":
        order   => '10',
        target  => "${::bind::confdir}/views.conf",
        content => template('bind/view.erb'),
    }
}
