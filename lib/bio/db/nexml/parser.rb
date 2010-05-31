require "elements"

require "rubygems"
require "xml"

require "ruby-debug"
#Debugger.start

module Bio
  module NeXML
    include LibXML

    def self.parse( nexml )
      Parser.new( nexml )
    end

    class Parser
      attr_reader :version, :generator, :otus, :trees

      def initialize( nexml, validate = false )
        #initialize a libxml cursor
        @reader = read( nexml )

        validate_nexml if validate

        #start at the root element
        move_to( "nexml" )

        #initialize the version and the generator
        @version = @reader[ 'version' ]
        @generator = @reader[ 'generator' ]

        #perhaps a namespace api as well
        
        #parse all the 'otus' element
        @otus = parse_all_otus

        #parse all the 'trees' element
        @trees = parse_all_trees
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

      #Close the assosicated XML::Reader object
      def close
        @reader.close
      end

      private

      def validate_nexml
        valid = @reader.schema_validate( "schema/nexml.xsd" )
        return true if valid == 0
      end

      #Move to an element. If the element is not found the method will run into an infinite loop
      #so use it carefully.
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

      #When this function is called the cursor will be at 'nexml' element.
      #This function will parse all 'otus' element and return an array of
      #'otus' objects.
      def parse_all_otus
        #Move to the first 'otus'
        move_to( "otus" )

        otus = []
        while element?( 'otus' )
          otus << parse_each_otus
          @reader.read
        end

        otus
      end

      #When this function is called the cursor will be at one of the
      #'otus' element. This function returns an object corresponding
      #to an individual 'otus' element.
      def parse_each_otus
        #create a new otus
        otus = NeXML::Otus.new( @reader[ 'id' ], @reader[ 'label' ] )

        #parse all its child 'otu' elements
        otus.otu = parse_all_otu

        otus
      end

      #When this function is called the cursor will be at on of the
      #'otus' element. This function will parse all the child 'otu'
      #elements and return an array of 'otu' objects.
      def parse_all_otu
        #Move to the first 'otu'
        move_to( "otu" )

        otu = []
        #parse the child 'otu's
        while element?( "otu" )
          otu << parse_each_otu
          @reader.read
        end

        otu
      end

      #When this function is called the cursor will be at one of the
      #'otu' element. This function returns an object corresponding
      #to an individual 'otu' element.
      def parse_each_otu
        Otu.new( @reader[ 'id' ], @reader[ 'label' ] )
      end

      #When this function is called the cursor will be at the last 'otus'
      #element. This function will parse all 'trees' element and return an
      #array of 'trees' objects.
      def parse_all_trees
        #Move to the first 'trees'
        move_to( "trees" )

        trees = []
        while element?( 'trees' )
          trees << parse_each_trees
          @reader.read
        end

        trees
      end

      #When this function is called the cursor will be at one of the
      #'trees' element. This function returns an object corresponding
      #to an individual 'trees' element.
      def parse_each_trees
        #create a new tree
        trees = NeXML::Trees.new( @reader[ 'id' ], @reader[ 'label' ] )

        #parse all its child 'tree' elements
        trees.tree = parse_all_tree

        trees
      end

      #When this function is called the cursor will be at one of the
      #'trees' element. This function will parse all child 'tree' element
      #and return an array of 'tree' objects.
      def parse_all_tree
        #Move the cursor to the first tree
        move_to( 'tree' )

        tree = []
        while element?( 'tree' )
          tree << parse_each_tree
          @reader.read
        end

        tree
      end

      #When this function is called the cursor will be at one of the
      #'tree' element. This function returns an object corresponding
      #to an individual 'tree' element.
      def parse_each_tree
        tree = NeXML::Tree.new( @reader[ 'id' ], @reader[ 'label' ] )

        #parse all its nodes
        parse_all_node( tree )

        #parse all its edges
        parse_all_edge( tree )

        tree
      end

      #When this function is called the cursor will be at one of the
      #'tree' element. This function parses the nodes of the tree and
      #returns an array of 'node' objects.
      def parse_all_node( tree )
        #Move the cursor to the first node
        move_to( 'node' )

        while element?( "node" )
          node = parse_each_node
          tree.add_node( node )
          @reader.read
        end
      end

      #When this function is called the curso is at one of the 'node'.
      #This fucntion returns a 'node' object.
      def parse_each_node
        NeXML::Node.new( @reader[ 'id' ], @reader[ 'label' ] )
      end

      #When this function is called the cursor is at the last 'node'
      #element. This function parses all the edges of the tree and 
      #returns an array of edge objects.
      def parse_all_edge( tree )
        move_to( 'edge' )

        while element?( 'edge' )
          edge = parse_each_edge
          @reader.read
        end

      end

      #When this function is called the cursor is at an edge.
      #This function returns an edge object.
      def parse_each_edge
        NeXML::Edge.new( @reader[ 'id' ], @reader[ 'source' ],
                         @reader[ 'target' ], @reader[ 'length' ],
                         @reader[ 'label' ] )
      end

    end #end Parser class

  end #end NeXML module

end #end Bio module

n = Bio::NeXML.parse "examples/test.xml"
puts "hi"
#Debugger.stop
