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
    context "#origin=" do
      should "append . if unqualified" do
        @zone.origin = "example.com"
        assert_equal "example.com.", @zone.origin
      end
      should "not append . if qualified" do
        @zone.origin = "example.com."
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
    context "#qualified_records" do
      setup do
        @records = @zone.qualified_records
        @olen = @zone.origin.length
      end
      should "expand all @ origins" do
        assert @records.all? { |r| r[:owner] != "@" }
      end
      should "qualify all owner fields" do
        assert @records.all? { |r| if r[:owner] then r[:owner][-@olen, @olen] == @zone.origin else true end }
      end
      should "qualify all target fields" do
        assert @records.all? { |r| if r[:target] then r[:target][-@olen, @olen] == @zone.origin else true end }
      end
      should "qualify all mbox fields" do
        assert @records.all? { |r| if r[:mbox] then r[:mbox][-@olen, @olen] == @zone.origin else true end }
      end
      should "qualify all domain fields" do
        assert @records.all? { |r| if r[:domain] then r[:domain][-@olen, @olen] == @zone.origin else true end }
      end
    end
  end
end
