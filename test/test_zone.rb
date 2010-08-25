require 'helper'

class TestBindZone < Test::Unit::TestCase
  context ".load_file" do
    setup do
      @zone_file = File.expand_path('../examples/example.com.db', __FILE__)
    end
    should "return new zone with the records from the file" do
      @zone = Bind::Zone.load_file(@zone_file)
      assert !@zone.records.empty?
    end
  end
end
