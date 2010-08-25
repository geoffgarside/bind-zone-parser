module Bind
  class Zone
    def self.load_file(path)
      new(File.read(path))
    end
    def initialize(zone)
      @records = ZoneParser.parse(zone)
    end
  end
end
