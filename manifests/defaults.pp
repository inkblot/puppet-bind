# ex: syntax=puppet si ts=4 sw=4 et

class bind::defaults (
    $supported              = undef,
    $confdir                = undef,
    $namedconf              = undef,
    $cachedir               = undef,
    $logdir                 = undef,
    $random_device          = undef,
    $bind_user              = undef,
    $bind_group             = undef,
    $bind_package           = undef,
    $bind_service           = undef,
    $nsupdate_package       = undef,
    $managed_keys_directory = undef,
    $default_zones_include  = undef,
    $default_zones_source   = undef,
    $isc_bind_keys          = undef,
) {
    unless is_bool($supported) {
        fail('Please ensure that the dependencies of the bind module are installed and working correctly')
    }
    unless $supported {
        fail('Platform is not supported')
    }
}
