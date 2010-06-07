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
        version = attribute( 'version' )
        generator = attribute( 'generator' )
        @nexml = NeXML::Nexml.new( version, generator )

        #perhaps a namespace api as well
        
        #start parsing other elements
        while next_node
          case local_name
          when "otus"
            @nexml.add_otus( parse_otus )
          when "trees"
            @nexml.add_trees( parse_trees )
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

      def attribute( name )
        @reader[ name ]
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
        id = attribute( 'id' )
        label = attribute( 'label' )

        otus = NeXML::Otus.new( id, label )

        #according to the schema an 'otus' may have no child element.
        return otus if empty_element?

        #else, parse child elements
        while next_node
          case local_name
          when "otu"
            #parse child otu element
            otus << parse_otu
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
        id = attribute( 'id' )
        label = attribute( 'label' )

        otu = NeXML::Otu.new( id, label )

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
        #if the trees is taxa linked
        if taxa = attribute( 'otus' )
          otus = @nexml.otus_set[ taxa ]
        end

        id = attribute( 'id' )
        label = attribute( 'label' )

        trees = NeXML::Trees.new( id, label, otus )

        #a 'trees' element *will* have child nodes.
        while next_node
          case local_name
          when "tree"
            #parse child 'tree' element
            trees << parse_tree
          when "network"
            trees << parse_network
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
        id = attribute( 'id' )
        label = attribute( 'label' )

        type = attribute( 'xsi:type' )[4..-1]
        klass = NeXML.const_get type
        tree = klass.new( id, label )

        #a 'tree' element *will* have child nodes.
        while next_node
          case local_name
          when "node"
            #parse child 'node' element
            node = parse_node

            #and add it to the 'tree'
            tree.add_node node

            #root?
            tree.root << node if node.root?
          when "rootedge"
            #parse child 'edge' element
            rootedge = parse_rootedge( type )

            #and add it to the 'tree'
            tree.add_rootedge rootedge
          when "edge"
            #parse child 'edge' element
            edge = parse_edge( type )

            #and add it to the 'tree'
            tree.add_edge edge
          when "tree"
            #end of current 'tree' element has been reached
            break
          end
        end

        #return the 'tree' object
        tree
      end

      def parse_network
        id = attribute( 'id' )
        label = attribute( 'label' )

        type = attribute( 'xsi:type' )[4..-1]
        klass = NeXML.const_get type
        network = klass.new( id, label )

        #a 'network' element *will* have child nodes.
        while next_node
          case local_name
          when "node"
            #parse child 'node' element
            node = parse_node

            #and add it to the 'network'
            network.add_node node

            #root?
            network.root = node if node.root?
          when "edge"
            #parse child 'edge' element
            edge = parse_edge( type )

            #and add it to the 'network'
            network.add_edge edge

          when "network"
            #end of current 'network' element has been reached
            break
          end
        end

        #return the 'network' object
        network
      end

      #When this function is called the cursor is at a 'node' element.
      #Return - a 'node' object.
      def parse_node
        id = attribute( 'id' )
        label = attribute( 'label' )
        root = attribute( 'root' ) ? true : false

        #is this node taxon linked
        if otu_id = attribute( 'otu' )
          otu = @nexml.get_otu_by_id otu_id
        end

        node = NeXML::Node.new( id, label, otu, root )

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
      def parse_edge( type )
        id = attribute( 'id' )
        source = attribute( 'source' )
        target = attribute( 'target' )
        length = attribute( 'length' )
        
        type.sub!(/Tree|Network/, "Edge")
        klass = NeXML.const_get type
        edge = klass.new( id, source, target, length )

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

      def parse_rootedge( type )
        id = attribute( 'id' )
        target = attribute( 'target' )
        length = attribute( 'length' )
        
        rootedge = RootEdge.new( id, target, length )

        #according to the schema an 'edge' may have no child element.
        return rootedge if empty_element?

        while next_node
          case local_name
          when 'rootedge'
            #end of current 'rootedge' element has been reached
            break
          end
        end

        #return the 'rootedge' object
        rootedge
      end

    end #end Parser class

  end #end NeXML module

end #end Bio module

#n = Bio::NeXML.parse "examples/test.xml"
#Debugger.stop
