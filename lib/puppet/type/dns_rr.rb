Puppet::Type.newtype(:dns_rr) do
  @doc = "A Resource Record in the DNS"

  Puppet.warning('The dns_rr resource type is deprecated. Use resource_record instead')

  ensurable

  newparam(:spec, :namevar => true) do
    desc "Class/Type/Name for the resource record"

    validate do |value|
      if (value =~ /^([A-Z]+)\/([A-Z]+)\/((\*\.)?([a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+)$/)
        rrclass = $1
        if ( !%w(IN CH HS).include? rrclass )
          Util::Errors.fail "Invalid resource record class: %s" % rrdata
        end
        type = $2
        if ( !%w(A AAAA CNAME NS MX SPF SRV NAPTR PTR TXT DS).include? type)
          Util::Errors.fail "Invalid resource record type: %s" % type
        end
      else
        Util::Errors.fail "%s must be of the form Class/Type/Name" % value
      end
    end
  end

  newproperty(:ttl) do
    desc 'Time to live of the resource record'
    defaultto 43200

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:rrdata, :array_matching => :all) do
    desc 'The resource record\'s data'
    isrequired

    def insync?(is)
      Array(is).sort == Array(@should).sort
    end
  end

  newparam(:zone) do
    desc 'The zone to update'
  end

  newparam(:server) do
    desc 'The master server for the resource record'
    defaultto 'localhost'
  end

  newparam(:query_section) do
    desc 'The DNS response section to check for existing record values'
    defaultto 'answer'
    newvalues 'answer', 'authority', 'additional'
  end

  newparam(:keyname) do
    desc 'Keyname for the TSIG key used to update the record'
    defaultto 'update'
  end

  newparam(:hmac) do
    desc 'The HMAC type of the update key'
    defaultto 'HMAC-SHA1'
  end

  newparam(:secret) do
    desc 'The secret of the update key'
  end

end
