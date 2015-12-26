# ex: syntax=puppet si ts=4 sw=4 et

class bind::defaults (
    $supported              = undef,
    $confdir                = undef,
    $namedconf              = undef,
    $cachedir               = undef,
    $random_device          = undef,
    $bind_user              = undef,
    $bind_group             = undef,
    $bind_package           = undef,
    $bind_service           = undef,
    $nsupdate_package       = undef,
    $managed_keys_directory = undef,
) {
    unless $supported {
        fail('Platform is not supported')
    }
}
