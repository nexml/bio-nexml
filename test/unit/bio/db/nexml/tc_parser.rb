module Bio
  module NeXML
    class TestParser < Test::Unit::TestCase

      def setup
        @doc = Parser.new( TEST_FILE, true )
      end

      def teardown
        @doc.close if @doc
      end

      def test_parse
        nexml = @doc.parse
        assert_instance_of Bio::NeXML::Nexml, nexml, "Should return an object of Bio::NeXML::Nexml"
      end

    end #end class TestParser
  end #end module NeXML

end #end module Bio
