require "elements"

require "rubygems"
require "libxml"

module Bio
  module NeXML

    def self.parse( nexml )
      Parser.new( nexml )
    end

    class Parser
      attr_reader :version, :generator

      def initialize( nexml )
        #initialize a libxml cursor
        @reader = read( nexml )

        #start at the root element
        move_to( "nexml" )

        #initialize the version and the generator
        @version = @reader[ 'version' ]
        @generator = @reader[ 'generator' ]

        #perhaps a namespace api as well
      end

      #Determine if the 'nexml' is a file, string, or an io
      #and accordingly return a XML::Reader object.
      def read( nexml )
        case nexml
        when /\.xml$/
          XML::Reader.file( nexml, :options => XML::Parser::Options::NOBLANKS )
        when IO
          XML::Reader.io( nexml, :options => XML::Parser::Options::NOBLANKS )
        when String
          XML::Reader.string( nexml, :options => XML::Parser::Options::NOBLANKS )
        end
      end

      #Move to the given element.
      #This function should be used carefully.
      #Since libxml's cursor only moves in the forward direction
      #it will reach the end of the document if the 'element' is 
      #not found rendering the cursor useless for any further
      #usage.
      #def move_to( element )
        #while @reader.read do
          #return element if element?( element )
        #end
      #end
      def move_to( element )
        @reader.read until element?( element )
      end

      #Check if 'name'( without prefix ) is an element node or not.
      def element?( name )
        ( @reader.node_type == XML::Reader::TYPE_ELEMENT ) and ( @reader.local_name == name )
      end

      #Check if 'name'( without prefix ) is the end of an element or not.
      def end_element?( name )
        ( @reader.node_type == XML::Reader::TYPE_END_ELEMENT ) and ( @reader.local_name == name )
      end

      #Close the assosicated XML::Reader object
      def close
        @reader.close
      end

      def otus
        #return any existing otus
        return @otus_set if @otus_set

        #assuming the cursor is before the first otus
        #move the cursor to the first otus
        @reader.read until element?( "otus" )

        @otus_set = []
        while element?( 'otus' )
          @otus_set << parse_otus
          @reader.read
        end

        @otus_set
      end

      def parse_otus
        #create a new otus
        @otus = NeXML::Otus.new( @reader[ 'id' ], @reader[ 'label' ] )

        #parse the child 'otu's
        until end_element?( "otus" )
          @reader.read
          if element?( "otu" )
            otu = Otu.new( @reader[ 'id' ], @reader[ 'label' ] )
            @otus.otu << otu
          end
        end

        #return the newly create otu object
        @otus
      end
      
      def trees
        #return any existing otus
        return @trees_set if @trees_set

        #assuming the cursor is before the first trees
        #move the cursor to the first otus
        @reader.read until element?( "trees" )

        @trees_set = []
        while element?( 'trees' )
          @trees_set << parse_trees
          @reader.read
        end

        @trees_set
      end

      def parse_trees
        @trees = NeXML::Trees.new( @reader[ 'id' ], @reader[ 'label' ] )

        #parse the child 'tree's
        until end_element?( "trees" )
          @reader.read
          if element?( "tree" )
            tree = NeXML::Tree.new( @reader[ 'id' ], @reader[ 'label' ] )
            @trees.tree << tree
          end
        end

        #return the newly create trees object
        @trees
      end

    end #end Parser class

  end #end NeXML module

end #end Bio module
