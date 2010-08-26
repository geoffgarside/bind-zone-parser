require 'helper'

class TestBindZone < Test::Unit::TestCase
  context "Bind::Zone" do
    setup do
      @zone_file = File.expand_path('../examples/example.com.db', __FILE__)
      @zone = Bind::Zone.load_file(@zone_file)
    end
    context ".load_file" do
      should "return new zone with the records from the file" do
        assert !@zone.records.empty?
      end
    end
    context "#origin" do
      should "get origin from zone $ORIGIN definition" do
        assert_equal "example.com.", @zone.origin
      end
    end
    context "#records" do
      setup do
        @records = @zone.records
      end
      should "not be empty" do
        assert !@records.empty?
      end
      should "change any blank owners to named" do
        assert @records.all? { |r| r[:owner] != "" }
      end
    end
  end
end
