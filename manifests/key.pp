# ex: syntax=puppet si ts=4 sw=4 et

define bind::key (
    $secret,
    $algorithm = 'hmac-sha256',
    $owner     = 'root',
    $group     = $bind::params::bind_group,
) {
    $keydir = $::bind::keydir::keydir

    file { "${keydir}/${name}":
        ensure  => present,
        owner   => $owner,
        group   => $group,
        mode    => '0640',
        content => template('bind/key.conf.erb'),
    }

    if (defined(Class['bind'])) {
        Package['bind'] -> File["${keydir}/${name}"] ~> Service['bind']

        concat::fragment { "bind-key-${name}":
            order   => '10',
            target  => "${bind::confdir}/keys.conf",
            content => "include \"${bind::confdir}/keys/${name}\";\n",
        }
    }
}
