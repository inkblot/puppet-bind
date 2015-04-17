require 'tempfile'

module PuppetBind
  module Provider

    def self.nsupdate_provider(type)
    end

    module NsUpdate

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

    private

      def update(&block)
        file = Tempfile.new('dns_rr-nsupdate-')
        file.write "server #{server}\n"
        file.write "zone #{zone}\n" unless zone.nil?
        yield file
        file.write "send\n"
        file.close
        if keyed?
          nsupdate('-y', tsig_param, file.path)
        elsif keyfile?
          nsupdate('-k', kfile, file.path)
        else
          nsupdate(file.path)
        end
        file.unlink
      end

      def accio(file)
        newdata.each do |datum|
          file.write "update add #{name}. #{resource[:ttl]} #{rrclass} #{type} #{datum}\n"
        end
      end

      def destructo(file)
        rrdata.each do |datum|
          file.write "update delete #{name}. #{ttl} #{rrclass} #{type} #{datum}\n"
        end
      end

      def server
        resource[:server]
      end

      def zone
        resource[:zone]
      end

      def keyname
        resource[:keyname]
      end

      def kfile
        resource[:keyfile]
      end

      def keyfile?
        !kfile.nil?
      end

      def hmac
        resource[:hmac]
      end

      def secret
        resource[:secret]
      end

      def keyed?
        !secret.nil?
      end

      def tsig_param
        "#{hmac}:#{keyname}:#{secret}"
      end

      def query
        unless @query
          if keyed?
            dig_text = dig("@#{server}", '+noall', '+answer', name, type, '-c', rrclass, '-y', tsig_param)
          else
            dig_text = dig("@#{server}", '+noall', '+answer', name, type, '-c', rrclass)
          end
          @query = dig_text.lines.map do |line|
            linearray = line.chomp.split(/\s+/, 5)
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
  end
end
