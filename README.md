# bind

[![Build Status](https://secure.travis-ci.org/inkblot/puppet-bind.png)](http://travis-ci.org/inkblot/puppet-bind)

**IMPORTANT UPGRADE INFORMATION:** In version 6.0.0 of this module there are
significant changes to the handling of default zones that may require
preparations prior to upgrading. See [DEFAULT_ZONES.md](DEFAULT_ZONES.md) for
details.

## Summary

Control BIND name servers and zones

## Description

The BIND module provides an interface for managing a BIND name server, including installation of software, configuration
of the server, creation of keys, and definitions for zones.

## What BIND affects

* package installation and service control for BIND
* configuration of the server, zones, acls, keys, and views
* creation of TSIG and DNSSEC keys

# Usage

## Dependencies

The BIND module depends on [ripienaar/module_data](https://forge.puppetlabs.com/ripienaar/module_data) for hiera module
data support and [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) for certain parser functions. When
using the BIND module, please install the module using `puppet module install` or an equivalent substitute in order to
ensure that its dependencies are met.

## Getting started

To begin using the BIND module with default parameters, declare the class

```
class { 'bind': }
```

Puppet code that uses anything from the BIND module requires that the core bind classes be declared.

## Classes

### `bind`

`bind` provides a few parameters that control server-level configuration parameters in the `named.conf` file, and also
defines the overall structure of DNS service on the node.

```
class { 'bind':
    forwarders => [
        '8.8.8.8',
        '8.8.4.4',
    ],
    dnssec     => true,
    version    => 'Controlled by Puppet',
}
```

Puppet will manage the entire `named.conf` file and its includes. Most parameters are set to a fixed value, but the
server's upstream resolvers are controlled using `forwarders`, enabling of DNSSec signature validation is controlled
using `dnssec`, and the reported version is controlled using `version`. It is unlikely that you will need to define an
alternate value for `confdir` or `cachedir`.

### `bind::updater`

The `bind::updater` class is an alternate entrypoint into the module. This class installs the BIND client tools but not
a name server. The installed tools are sufficient to allow the use of the `resource_record` custom resource.

## Defines

### `bind::key`

Creates a TSIG key file. Only the `secret` parameter is required, but it is recommended to explicitly supply the
`algorithm` as well. The key file will be stored in `${::bind::confdir}/keys` with a filename derived from the title of
the `bind::key` declaration.

```
bind::key { 'local-update':
    algorithm => 'hmac-sha256', # default: 'hmac-sha256'
    secret    => '012345678901345678901234567890123456789=',
    owner     => 'root',
    group     => 'bind',
}
```

If no secret is specified, the bind::key define will generate one. The secret_bits parameter controls the size of the
secret.

```
bind::key { 'local-update':
    secret_bits => 512, # default: 256
}
```

### `bind::acl`

Declares an acl in the server's configuration. The acl's name is the title of the `bind::acl` declaration.

```
bind::acl { 'rfc1918':
    addresses => [
        '10.0.0.0/8',
        '172.16.0.0/12',
        '192.168.0.0/16',
    ]
}

bind::acl { 'secondary-dns':
    addresses => '192.0.2.4/32',
}
```

### `bind::zone`

Declares a zone. Each zone must be included in at least one view in order to be included in the server's configuration,
and may be included in multiple views. The corresponding zone file will be created if it is absent, but any existing
file will not be overwritten. Only the `zone_type` is required. If `domain` is unspecified, the title of the
`bind::zone` declaration will be used as the domain.

A master zone with a zone file managed directly by Puppet:

```
bind::zone { 'example.org':
    zone_type       => 'master',
    dynamic         => false,
    source          => 'puppet:///dns/db.example.org',
    allow_transfers => [ 'secondary-dns', ],
}
```

A master zone with DNSSec disabled which allows updates using a TSIG key and zone transfers to servers matching an acl:

```
bind::zone { 'example.com-internal':
    zone_type       => 'master',
    domain          => 'example.com',
    allow_updates   => [ 'key local-update', ],
    allow_transfers => [ 'secondary-dns', ],
    ns_notify       => true,
    dnssec          => false,
}
```

A master zone with DNSSec enabled which allows updates using a TSIG key and zone transfers to servers matching an acl:

```
bind::zone { 'example.com-external':
    zone_type       => 'master',
    domain          => 'example.com',
    allow_updates   => [ 'key local-update', ],
    allow_transfers => [ 'secondary-dns', ],
    ns_notify       => true,
    dnssec          => true,
    key_directory   => '/var/cache/bind/example.com',
}
```

A master zone which is initialized with a pre-existing zone file (for example, to migrate an existing zone to a
bind-module controlled server or to recover from a backup):

```
bind::zone { 'example.com':
    zone_type => 'master',
    source    => 'puppet:///backups/dns/example.com',
}
```

A slave zone which allows notifications from servers matched by IP:

```
bind::zone { 'example.net':
    zone_type    => 'slave',
    masters      => [ '198.0.2.2' ],
    allow_notify => [ '192.0.2.2' ],
    ns_notify    => false,
}
```

A forward zone:

```
bind::zone { 'example.org':
    zone_type  => 'forward',
    forwarders => [ '10.0.2.4', ],
    forward    => 'only',
}
```

### `bind::view`

Declares a view in the BIND configuration. In order to declare zones in a server configuration there must be at least
one view declaration which includes the zones.

A common use for views is to use a single dual-homed nameserver as a resolver on a private network and an authoritative
non-resolving nameserver on the Internet. Furthermore, the Internet-facing and private network-facing views may present
different authoritative results for a domain. Given a BIND server connected to the internet with the address 198.0.2.2
and connected to a private network with the address 10.0.2.2, here are the `bind::view` declarations that would create
this configuration:

```
bind::view { 'internet':
    recursion          => false,
    match_destinations => [ '198.0.2.2', ],
    zones              => [ 'example.net', 'example.com-external', ],
}

bind::view { 'private':
    recursion          => true,
    match_destinations => [ '10.0.2.2', ],
    zones              => [ 'example.net', 'example.com-internal', ],
}
```

In this scenario, the example.com domain has two separate zones that are presented in each of the `internet` and
`private` views. These two zones are independent, and TSIG-signed updates to example.com must be made to either
198.0.2.2 or 10.0.2.2, to change the `internet` or `private` views of this domain. Updates to `example.net` may be made
via either address, since the zone is included in both views.

Another use for views is to control access to the DNS server's services. In this example, service is restricted to a
specific set of client address ranges, and queries for the `example.org` domain are handled using a declared zone (see
`bind::zone` declaration for `example.org` above):

```
bind::view { 'clients':
    recursion     => true,
    match_clients => [
        '10.10.0.0/24',
        '10.100.0.0/24',
    ],
    zones         => [
        'example.org',
    ],
}
```

View declarations can also include server clause configuration. The `servers` property of `bind::view` accepts an array
value which specifies each `server` clause in the view as a hash. The hash must contain an `ip_addr` key which specifies
the IP address (optionally, a CIDR address range), and may contain a `keys` key with a string value. The value of `keys`
will be used as the name of a key in the `server` clause. In this example, the `ns` view will contain a `server` clause
that configures BIND to use the key `internal-ns` to TSIG-sign transactions with `192.168.24.2` and the key
`hurricane-electric` to TSIG-sign transactions with `216.218.130.2`:

```
bind::view { 'ns':
    servers => [
        {
            'ip_addr' => '192.168.24.2',
            'keys'    => 'internal-ns',
        },
        {
            'ip_addr' => '216.218.130.2',
            'keys'    => 'hurricane-electric',
        }
    ],
    ...
}
```

## Resources

### `resource_record`

Declares a resource record. For example:

```
resource_record { 'www.example.com address':
    ensure  => present,
    record  => 'www.example.com',
    type    => 'A',
    data    => [ '172.16.32.10', '172.16.32.11' ],
    ttl     => 86400,
    zone    => 'example.com',
    server  => 'ns.example.com',
    keyname => 'local',
    hmac    => 'hmac-sha1',
    secret  => 'aLE5LA=='
}
```

This resource declaration will result in address records with the addresses 172.16.32.10 and 172.16.32.11 (`data`), a
TTL of 86400 (`ttl`) in the zone example.com (`zone`). Any updates necessary to create, update, or destroy these records
are authenticated using a TSIG key named 'local' (`keyname`) of the given type (`hmac`) with the given `secret`.

No semantic information is communicated in the resource title. It is strictly for disambiguation of resources within
Puppet.

`record` is required, and is the fully qualified record to be managed.

`type` is required, and is the record type. It must be one of: `A` `AAAA` `CNAME` `NS` `MX` `SPF` `SRV` `NAPTR` `PTR` or
`TXT`. Other DNS record types are not currently supported.

`rrclass` is the class of the record. The default value is `IN` and allowed values are `IN`, `CH`, and `HS`.

`data` is required, and may be a scalar value or an array of scalar values whose format conform to the type of DNS
resource record being created. `data` is an ensurable property and changes will be reflected in DNS. **Note**: for
record types that have a DNS name as either the whole value or a component of the value (e.g. `NS`, 'MX', `CNAME`,
`PTR`, `NAPTR`, or `SRV`) you must specify the name as a fully-qualified name with a trailing dot in order to satisfy
both BIND, which will otherwise consider it a name relative, and Puppet, which will not consider the dot-qualified
output of dig equal to a non-dot-qualified value in the manifest.

`ttl` defaults to 43200 and need not be specified. `ttl` is an ensurable property and changes will be reflected in DNS.

`zone` is not required, and generally not needed. It is only necessary to specify the zone to be updated if the target
nameserver has the record in multiple zones, e.g. the NS records of a zone whose parent zone is served by the same
nameserver.

`server` defaults to "localhost" and need not be specified. The value may be either a hostname or IP address.

`query_section` indicates the section of the DNS response to check for existing record values. It must be one of
`answer`, `authority`, or `additional`. Defaults to: `answer`

`keyname` defaults to "update" and need not be specified. This parameter specifies the name of a TSIG key to be used to
authenticate the update. The resource only uses a TSIG key if a `secret` is specified.

`keyfile` specifies the name of a key file to use to sign requests. This parameter has no effect if a `secret` is
specified.

`hmac` defaults to "hmac-sha1" and need not be specified. This parameter specifies the algorithm of the TSIG key to be
used to authenticate the update. The resource only uses a TSIG key if a `secret` is specified.

`secret` is optional. This parameter specifies the encoded cryptographic secret of the TSIG key to be used to
authenticate the update. If no `secret` is specified, then the update will not use TSIG authentication.

#### `resource_record` examples

Mail exchangers for a domain. Declares three mail exchangers for the domain `example.com`, which are `mx.example.com`,
`mx2.example.com`, and `mx.mail-host.ex` with priorities `10`, `20`, and `30`, respectively (note the trailing dots in
the values to denote fully-qualified names):

```
resource_record { 'example.com mail exchangers':
    record => 'example.com',
    type   => 'MX',
    data   => [ '10 mx.example.com.', '20 mx2.example.com.', '20 mx.mail-host.ex.', ],
}
```

Nameserver records for a zone. Declares three nameserver records for the zone `example.com`, which are
`ns1.example.com`, `ns2.example.com`, and `ns.dns-host.ex`:

```
resource_record { 'example.com name servers':
    record => 'example.com',
    type   => 'NS',
    data   => [ 'ns1.example.com.', 'ns2.example.com.', 'ns.dns-host.ex.' ],
}
```

Delegating nameserver records in a parent zone. Declares a nameserver record in the parent zone in order to delegate
authority for a subdomain:

```
resource_record { 'sub.example.com delegation':
    record        => 'sub.example.com'
    type          => 'NS',
    zone          => 'example.com',
    query_section => 'authority',
    data          => 'sub-ns.example.com.',
}
```

Service locators records for a domain. Declares a service locator for SIP over UDP to the domain `example.com`, in which
the service located at port `5060` of `inbound.sip-host.ex` is given priority `5` and weight `100`.

```
resource_record { 'example.com SIP service locator':
    record => '_sip._udp.example.com',
    type   => 'SRV',
    data   => [ '5 100 5060 inbound.sip-host.ex.', ],
}
```

## Troubleshooting

### Error message: "Please ensure that the dependencies of the bind module are installed and working correctly"

This error usually has one of two causes.

First of all, the `bind` module has dependencies. These are declared in the module manifest, and they are properly
installed via the [`puppet module install`](https://docs.puppetlabs.com/puppet/latest/reference/modules_installing.html)
command and when using [`librarian-puppet`](https://github.com/rodjek/librarian-puppet).

Secondly, after installing the module and its dependencies it is necessary to restart the Puppet master if you are using
master mode. The [`ripienaar/module_data`](https://github.com/ripienaar/puppet-module-data) module contains
functionality which is only loaded at startup.

### Error message: "Platform is not supported"

Support for specific platforms is explicit in this module. If you see this message and would like to try to make the
module work on your platform, you can do this by setting `bind::defaults::supported` to `true` in hiera, and then
overriding other parameters of the `bind::defaults` class as necessary to make the module work. If you succeed or if you
require help, please open an issue. I would be happy to include your changes in order to support additional platforms.
