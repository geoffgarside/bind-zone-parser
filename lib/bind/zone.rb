module Bind
  class Zone
    attr_reader :records
    attr_accessor :origin

    def self.load_file(path)
      new(File.read(path))
    end
    def initialize(zone)
      @parser = ZoneParser.new
      @records = @parser.parse(zone)
      @origin = @parser.origin
      update_blank_owners
    end
    def origin=(v)
      @origin = v
      @origin << '.' unless @origin[-1,1] == '.'
    end
    def qualified_records
      raise "Please set origin before calling this function" if @origin.nil?
      @records.map do |record|
        qualify_record(record.dup)
      end
    end
    protected
      def update_blank_owners
        last_owner = nil
        @records.each do |record|
          record[:owner] = last_owner if record[:owner] == ""
          last_owner = record[:owner]
        end
      end
      def qualify_record(record)
        [:owner, :target, :mbox, :domain].each do |key|
          if record.has_key?(key)
            record[key] = qualify_name(record[key])
          end
        end
        record
      end
      def qualify_name(dname)
        return if dname.nil?
        return @origin if dname == '@'
        "#{dname}.#{@origin}" if dname[-1,1] != '.'
      end
  end
end
