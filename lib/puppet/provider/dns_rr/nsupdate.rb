require 'tempfile'

Puppet::Type.type(:dns_rr).provide(:nsupdate) do
  commands :dig => 'dig', :nsupdate => 'nsupdate'

  def initialize(value={})
    super(value)
    @properties = {}
  end

  def exists?
    !(query.empty?)
  end

  def create
    update do |file|
      accio(file)
    end
  end

  def destroy
    update do |file|
      destructo(file)
    end
  end

  def flush
    return if @properties.empty?
    update do |file|
      destructo(file)
      accio(file)
    end
  end

  def ttl
    query.first[:ttl]
  end

  def ttl=(ttl)
    @properties[:ttl] = ttl
  end

  def rrdata
    query.map { |record| record[:rrdata] }.sort
  end

  def rrdata=(rrdata)
    @properties[:rrdata] = rrdata
  end

private

  def update(&block)
    file = Tempfile.new('dns_rr-nsupdate-')
    file.write "server #{server}\n"
    file.write "zone #{resource[:zone]}\n" unless resource[:zone].nil?
    yield file
    file.write "send\n"
    file.close
    if keyed?
      nsupdate('-y', tsig_param, file.path)
    else
      nsupdate(file.path)
    end
    file.unlink
  end

  def accio(file)
    resource[:rrdata].each do |datum|
      file.write "update add #{name}. #{resource[:ttl]} #{rrclass} #{type} #{datum}\n"
    end
  end

  def destructo(file)
    rrdata.each do |datum|
      file.write "update delete #{name}. #{ttl} #{rrclass} #{type} #{datum}\n"
    end
  end

  def keyed?
    !(resource[:secret].nil?)
  end

  def tsig_param
    "#{resource[:hmac]}:#{resource[:keyname]}:#{resource[:secret]}"
  end

  def server
    resource[:server]
  end

  def specarray
    resource[:spec].split('/')
  end

  def rrclass
    specarray[0]
  end

  def type
    specarray[1]
  end

  def name
    specarray[2]
  end

  def query
    unless @query
      @query = dig("@#{server}", '+noall', '+answer', name, type, '-c', rrclass).lines.map do |line|
        linearray = line.chomp.split /\s+/
        {
          :name    => linearray[0],
          :ttl     => linearray[1],
          :rrclass => linearray[2],
          :type    => linearray[3],
          :rrdata  => linearray[4]
        }
      end.select do |record|
        record[:name] == "#{name}."
      end
    end
    @query
  end

end
