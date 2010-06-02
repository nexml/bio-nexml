#require "ruby-debug"
#Debugger.start

module Bio
  module NeXML
    include LibXML

    #def self.parse( nexml, validate = false )
      #Parser.new( nexml, validate ).parse
    #end

    class Parser

      def initialize( nexml, validate = false )
        #initialize a libxml cursor
        @reader = read( nexml )
        
        #validate
        validate_nexml if validate

      end

      #Is a factory method that returns an object of class
      #Bio::NeXML::Nexml
      def parse
        #return a cached version if it exists
        return @nexml if @nexml

        #start at the root element
        skip_leader

        #start with a new Nexml object
        @nexml = NeXML::Nexml.new( @reader[ 'version' ], @reader[ 'generator' ] )

        #perhaps a namespace api as well
        
        #start parsing other elements
        while next_node
          case local_name
          when "otus"
            otus = parse_otus
            @nexml.id_hash[ "#{otus.id}" ] = otus
            @nexml.otus << otus
          when "trees"
            @nexml.trees << parse_trees
          when "characters"
            puts "characters"
          end
        end

        #close the libxml parser object
        #close

        #return the Nexml object
        @nexml
      end

      #Close the assosicated XML::Reader object
      #and try to free other resources like @nexml
      def close
        @reader.close
      end

      private

      #Determine if the 'nexml' is a file, string, or an io
      #and accordingly return a XML::Reader object.
      def read( nexml )
        case nexml
        when /\.xml$/
          XML::Reader.file( nexml, :options => parse_opts )
        when IO
          XML::Reader.io( nexml, :options => parse_opts )
        when String
          XML::Reader.string( nexml, :options => parse_opts )
        end
      end

      def skip_leader
        @reader.read until local_name == "nexml"
      end

      def local_name
        @reader.local_name
      end

      def next_node
        while @reader.read
          return true if element_start? or element_end?
        end
        false
      end

      #Define XML parsing options for the libxml parser.
      #1. remove blank nodes
      #2. substitute entities 
      #3. forbid network access
      def parse_opts
        XML::Parser::Options::NOBLANKS |
          XML::Parser::Options::NOENT  |
          XML:: Parser::Options::NONET
      end

      def validate_nexml
        valid = @reader.schema_validate( File.join( File.dirname(__FILE__),
                                                    "schema/nexml.xsd" ) )
        return true if valid == 0
      end

      #Check if 'name'( without prefix ) is an element node or not.
      def element_start?
        @reader.node_type == XML::Reader::TYPE_ELEMENT
      end

      #Check if 'name'( without prefix ) is the end of an element or not.
      def element_end?
        @reader.node_type == XML::Reader::TYPE_END_ELEMENT
      end

      def empty_element?
        @reader.empty_element?
      end

      #When this function is called the cursor is at an 'otus' element.
      #Return - an 'otus' object
      def parse_otus
        #start with a new 'otus' object
        otus = NeXML::Otus.new( @reader[ 'id' ], @reader[ 'label' ] )

        #according to the schema an 'otus' may have no child element.
        return otus if empty_element?

        #else, parse child elements
        while next_node
          case local_name
          when "otu"
            #parse child otu element
            otu = parse_otu
            @nexml.id_hash[ "#{otu.id}" ] = otu
            otus.otu << otu
          when "otus"
            #end of current 'otus' element has been reached
            break
          end
        end

        #return the 'otus' object
        otus
      end

      #When this function is called the cursor is at an 'otu' element.
      #Return - an 'otu' object.
      def parse_otu
        #start with a new 'otu' object
        otu = NeXML::Otu.new( @reader[ 'id' ], @reader[ 'label' ] )

        #according to the schema an 'otu' may have no child element.
        return otu if empty_element?

        while next_node
          case local_name
          when 'otu'
            #end of current 'otu' element has been reached
            break
          end
        end

        #return the 'otu' object
        otu
      end

      #When this function is called the cursor is at a 'trees' element.
      #Return - a 'trees' object.
      def parse_trees
        #start with a new 'trees' object
        trees = NeXML::Trees.new( @reader[ 'id' ], @reader[ 'label' ] )
        trees.otus = @nexml.id_hash[ @reader[ 'otus' ] ]

        #a 'trees' element *will* have child nodes.
        while next_node
          case local_name
          when "tree"
            #parse child 'tree' element
            trees.tree << parse_tree
          when "trees"
            #end of current 'trees' element has been reached
            break
          end
        end

        #return the 'trees' object
        trees
      end

      #When this function is called the cursor is at a 'tree' element.
      #Return - a 'tree' object.
      def parse_tree
        #start with a new 'tree' object
        tree = NeXML::Tree.new( @reader[ 'id' ], @reader[ 'label' ] )

        #a 'tree' element *will* have child nodes.
        while next_node
          case local_name
          when "node"
            #parse child 'node' element
            node = parse_node

            #and add it to the 'tree'
            tree.add_node( node )
          when "edge"
            #parse child 'edge' element
            edge = parse_edge

            #and add it to the 'tree'
            source_node = tree.get_node_by_name( edge.source )
            target_node = tree.get_node_by_name( edge.target )
            tree.add_edge( source_node, target_node )
          when "tree"
            #end of current 'tree' element has been reached
            break
          end
        end

        #return the 'tree' object
        tree
      end

      #When this function is called the cursor is at a 'node' element.
      #Return - a 'node' object.
      def parse_node
        #start with a new 'node' object
        node = NeXML::Node.new( @reader[ 'id' ], @reader[ 'label' ] )
        node.name = node.id

        otu = @nexml.id_hash[ @reader[ 'otu' ] ]
        node.otu = otu
        pp node.otu

        #according to the schema a 'node' may have no child element.
        return node if empty_element?

        #else, if 'node' has child elements
        while next_node
          case local_name
          when 'node'
            #end of current 'node' element has been reached
            break
          end
        end

        #return the 'node' object
        node
      end

      #When this function is called the cursor is at a 'edge' element.
      #Return - a 'edge' object.
      def parse_edge
        #start with a new 'edge' object
        edge = NeXML::Edge.new( @reader[ 'id' ], @reader[ 'source' ], @reader[ 'target' ] )

        #according to the schema an 'edge' may have no child element.
        return edge if empty_element?

        while next_node
          case local_name
          when 'edge'
            #end of current 'edge' element has been reached
            break
          end
        end

        #return the 'edge' object
        edge
      end

    end #end Parser class

  end #end NeXML module

end #end Bio module

#n = Bio::NeXML.parse "examples/test.xml"
#Debugger.stop
