# ex: syntax=puppet si ts=4 sw=4 et

class bind::params (
    $supported,
    $bind_user,
    $bind_group,
    $bind_package,
    $bind_service,
    $nsupdate_package,
    $dyndb_ldap_package,
) {
    unless $supported {
        fail('Platform is not supported')
    }
}
