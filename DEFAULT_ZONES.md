Default zones in BIND
=====================

<a name="default-zones"></a>
## What are default zones?

The package which installs the BIND server includes a stock configuration that
defines five default zones. One of these, the [root
hints](https://www.iana.org/domains/root/files), is necessary for the proper
functioning of a recursive resolver. The remaining four - `localhost`,
`0.in-addr.arpa`, `127.in-addr.arpa`, and `255.in-addr.arpa` - are defined for
compliance with [RFC 1912](https://www.ietf.org/rfc/rfc1912.txt). The content
of these zones is standardized, and the zone files for them are maintained by
the package distributor.

## Version 5.x vs. version 6.x of `puppet-bind`

<a name="warning"></a>
### The Warning

Most likely, you have reached this page because you have seen the notice on the
[README file](README.md) or a warning like this in your puppet logs:

```
The bind module will include a default definition for zone "localhost" starting in version 6.0.0.
```

If you are seeing this warning, it is because starting in version 6.0.0 certain
`bind::zone` definitions in your puppet manifests will result in an error and
catalog application failures. There are [steps](#configuration-changes) to take
prior to version 6.0.0 to prepare for it.

### Older versions: Debian and Red Hat Divergence

The treatment of default zones in versions 5.x and earlier of this module has
differed between Debian and Red Hat systems.

On Debian systems, the `bind9` package installs a separate configuration file
at `/etc/bind/named.conf.default-zones` which defines these zones and also
installs a stock `named.conf` which includes `named.conf.default-zones`. The
module retains the `named.conf.default-zones` configuration file and although
the module completely rewrites `named.conf`, it includes the default zones file
so that the default zones continues to be a part of the complete server
configuration.

On Red Hat systems, the default zones are defined in the stock version of
`named.conf` that the package installs. Since the module completely
rewrites this file, these definitions are lost.

In both cases, the current behavior is not configurable and always happens.

### Version 6.x and later: Consistency with Flexibility

Starting in version 6.0.0 of this module, default zones will be preserved on
both Debian and Red Hat, with the option of disabling them. This will not
result in any change in the behavior of the module on Debian systems, but on
Red Hat systems existing puppet manifests which use this module to configure a
nameserver may require modification in order to work with the newer version of
the module.

<a name="configuration-changes"></a>
## Configuration Changes

If you are seeing [the warning](#warning) in your puppet logs, you must take
action before upgrading to version 6.0.0 of this module. You are seeing the
warning because your puppet manifests include `bind::zone` definitions for one
or more of the [default zones](#default-zones). No action is necessary unless
you are seeing the warning.

### Before Upgrading

The step that you must take prior to upgrading to version 6.0.0 of the module
is to disable default zone inclusion. Setting this parameter has no effect in
5.x versions of this module other than to mute the warning but disabling the
feature will allow you to safely upgrade to 6.0.0. You can specify this as a
class parameter in the manifest where you use the `bind` class:

```
class { 'bind':
  ...
  include_default_zones => false,
}
```

Or you can override the class parameter via a hiera key:

```
bind::include_default_zones: false
```

Once this is done, you may safely upgrade to version 6.0.0.

### After Upgrading

After the upgrade, you will have the option of letting the module define your
default zones. However, when you reenable default zone inclusion you must also
remove your custom `bind::zone` definitions for the root zone `.`, `localhost`,
`0.in-addr.arpa`, `127.in-addr.arpa`, and `255.in-addr.arpa`.
