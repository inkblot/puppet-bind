Puppet::Type.newtype(:resource_record) do
  @doc = 'A Resource Record in the Domain Name System'

  ensurable

  newparam(:title, :namevar => true) do
    desc 'A unique name for the puppet resource'
  end

  newparam(:rrclass) do
    desc 'The record class'
    defaultto 'IN'
    newvalues 'IN', 'CH', 'HS'
  end

  newparam(:type) do
    desc 'The record type'
    isrequired
    newvalues 'A', 'AAAA', 'CNAME', 'NS', 'MX', 'SPF', 'SRV', 'NAPTR', 'PTR', 'TXT'
  end

  newparam(:record) do
    desc 'The fully-qualified record name'
    isrequired

    validate do |value|
      Util::Errors.fail "Invalid value for record: #{value}" unless value =~ /^([a-zA-Z0-9_-]+\.)*[a-zA-Z0-9_-]+$/
    end
  end

  newparam(:zone) do
    desc 'The zone to update'
  end

  newparam(:server) do
    desc 'The master server for the resource record'
    defaultto 'localhost'
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

  newproperty(:ttl) do
    desc 'Time to live of the resource record'
    defaultto 43200

    munge do |value|
      Integer(value)
    end
  end

  newproperty(:data, :array_matching => :all) do
    desc 'The resource record\'s data'
    isrequired

    def insync?(is)
      Array(is).sort == Array(@should).sort
    end
  end

end
