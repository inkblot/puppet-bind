# ex: syntax=puppet si ts=4 sw=4 et

class bind::keydir (
    $keydir,
) {
    file { $keydir:
        ensure => directory,
        mode   => '0755',
    }
}
