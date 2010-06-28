#Test suite for nexml lib.

# loading helper routine for testing bioruby
require 'pathname'
load Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4,
                            'bioruby_test_helper.rb')).cleanpath.to_s

# libraries needed for the tests
require 'test/unit'

require 'rubygems'
require 'bio/db/nexml/nexml'

module Bio
  module NeXML
    TEST_FILE = File.join(File.dirname(__FILE__), ['..'] * 4, "data", "nexml", "test.xml" )
  end
end

#run the tests
#require File.join(File.dirname(__FILE__), 'tc_parser' )
#require File.join(File.dirname(__FILE__), 'tc_elements' )
require File.join(File.dirname(__FILE__), 'tc_writer' )
