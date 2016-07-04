begin
  require 'puppet_bind/provider/nsupdate'
rescue LoadError
  require 'pathname' # WORK_AROUND #14073 and #7788
  nsupdate = Puppet::Module.find('dns', Puppet[:environment].to_s)
  raise(LoadError, "Unable to find nsupdate module in modulepath #{Puppet[:basemodulepath] || Puppet[:modulepath]}") unless nsupdate
  require File.join nsupdate.path, 'lib/puppet_bind/provider/nsupdate'
end

Puppet::Type.type(:resource_record).provide(:nsupdate) do

  include PuppetBind::Provider::NsUpdate

  commands :dig => 'dig', :nsupdate => 'nsupdate'

  def initialize(value={})
    super(value)
    @properties = {}
  end

  def data
    query.map { |record| record[:rrdata] }.sort
  end

  def data=(data)
    @properties[:rrdata] = data
  end

private

  def rrdata
    data
  end

  def newdata
    resource[:data]
  end

  def rrclass
    resource[:rrclass]
  end

  def type
    resource[:type].to_s
  end

  def name
    resource[:record]
  end

end
