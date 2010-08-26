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
    protected
      def update_blank_owners
        last_owner = nil
        @records.each do |record|
          record[:owner] = last_owner if record[:owner] == ""
          last_owner = record[:owner]
        end
      end
  end
end
