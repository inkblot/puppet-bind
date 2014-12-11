# ex: syntax=puppet si ts=4 sw=4 et

define bind::key (
    $algorithm = 'hmac-sha256',
    $owner     = 'root',
    $group     = $bind::params::bind_group,
    $secret,
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
        Package[$bind::params::bind_package] ->
        File["${keydir}/${name}"] ~>
        Service[$bind::params::bind_service]

        concat::fragment { "bind-key-${name}":
            order   => '10',
            target  => "${bind::confdir}/keys.conf",
            content => "include \"${bind::confdir}/keys/${name}\";\n",
        }
    }
}
