# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'

require 'rubygems'
require 'bio/db/nexml/parser'
require 'bio/db/nexml/elements'

module Bio
  module NeXML
    class TestParser

      def initialize
        doc = Parser.new( "test.xml", true )
        @nexml = doc.parse
        doc.close
      end

      def test_for_otus
        assert_not_nil @nexml.otus, "An NeXML document must have atleast one otus element."
      end

      def test_otus_for_id
        @nexml.otus.each do |otus|
          assert_not_nil otus.id, "An otus element must have an id"
        end
      end

      def teardown
        @nexml = nil
      end
    end #end class TestParser

  end #end module NeXML

end #end module Bio
