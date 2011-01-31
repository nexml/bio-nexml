require 'test/unit'
require 'bio/db/nexml'

module Bio
  module NeXML
    TEST_FILE = File.join(File.dirname(__FILE__), "data", "nexml", "test.xml" )
  end
end

require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_mapper' )
require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_matrix' )
require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_parser' )
require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_taxa' )
require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_trees' )
#require File.join(File.dirname(__FILE__), "unit", "bio", "db", "nexml", 'tc_writer' )

