# ex: syntax=puppet si ts=4 sw=4 et

define bind::key (
    $algorithm = 'hmac-sha256',
    $secret,
    $owner     = 'root',
    $group     = $bind::params::bind_group,
    path       = "${::bind::confdir}/keys"
) {
    file { "${path}/${name}":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        content => template('bind/key.conf.erb'),
        notify  => Service[$bind::params::bind_service],
        require => Package[$bind::params::bind_package],
    }
    if (defined(Class['bind'])) {
        concat::fragment { "bind-key-${name}":
            order   => '10',
            target  => "${bind::confdir}/keys.conf",
            content => "include \"${bind::confdir}/keys/${name}\";\n",
        }
    }
}
