module Bio
  module NeXML
    include LibXML

    # Add a helper function to the array class.
    Array.class_eval do

      # Takes an array as argument and checks if that array is a subset of <tt>self</tt>.
      # >> a = 1, 2, 3, 4, 5
      # >> a.has? [1, 4]
      # => true
      # >> a.has? [2, 6]
      # => false
      # >> a.has? [1, 1]
      # => true
      def has?( arg )
        arg.each { |a| return false unless include?( a ) }
        true
      end

    end

    # Add helper functions to XML::Node class.
    XML::Node.class_eval do

      # Assign namespaces to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * namespaces - a hash of prefix, uri pairs. It delegates the actual addition
      # to the <tt>namespace=</tt> method.
      # >> node = XML::Node.new( 'nexml' )
      # >> node.namespaces = { :nex => "http://www.nexml.org/1.0" }
      # >> node.namespaces = { nil => "http://www.nexml.org/1.0" }
      # >> node
      # => <nexml xmlns:nex="http://www.nexml.org/1.0" xmlns="http://www.nexml.org/1.0"/>
      def namespaces=( namespaces )
        namespaces.each do |prefix, prefix_uri|
          self.namespace = prefix, prefix_uri
        end
      end

      # Assign attributes to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * attributes - a hash of name, value pairs. It delegates the actual addition
      # to the <tt>attribute=</tt> method.
      # >> node = XML::Node.new( 'nexml' )
      # >> node.attributes = { :version => '0.9' }
      # >> node
      # => <nexml version="0.9"/>
      def attributes=( attributes )
        attributes.each do |name, value|
          self.attribute = name, value
        end
      end

      # Assign a single attribte to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * pair - an array whose first value is the attribute's name and
      # the second value is the attribute's value.
      # >> node = XML::Node.new( 'nexml' )
      # >> node.attribute = 'version', '0.9'
      # >> node
      # => <nexml version="0.9"/>
      def attribute=( pair )
        XML::Attr.new( self, pair.first.to_s, pair.last )
      end

      # Assing a single namespace to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * pair - an array whose first value is the namespace prefix and
      # the second value is the namespace uri. Use <tt>nil</tt> as a prefix
      # to create a default namespace.
      # >> node = XML::Node.new( 'nexml' )
      # >> node.namespace = 'nex', "http://www.nexml.org/1.0"
      # >> node.namespace = nil, 'http://www.nexml.org/1.0'
      # >> node
      # => <nexml xmlns:nex="http://www.nexml.org/1.0" xmlns="http://www.nexml.org/1.0"/>
      def namespace=( pair )
        # have to check for a nil prefix
        prefix = ( p = pair.first ) ? p.to_s : p
        XML::Namespace.new( self, prefix, pair.last )
      end

    end

    class Writer
      # = DESCRIPTION
      # Bio::NeXML::Writer class provides a wrapper over libxml-ruby to create any NeXML document.
      # This class defines a set of serialize_* instance methods which can be called on the appropriate
      # object to get its NeXML representation. The method returns a XML::Node object.
      # To get the raw NeXML representation to_s method should be called on the return value.
      # = EXAMPLES
      # A lot of examples of creating nexml objects and then serializing them
      # can be found in the tests "test/unit/bio/db/nexml/tc_writer.rb"
      def initialize( filename = nil, indent = true )
        @filename = filename
        @indent = indent
        @doc = XML::Document.new
        @root = root
        @doc.root = @root
      end

      # Add one or more <em>otus</em>, <em>trees</em>, or <em>characters</em> objects to <tt>self</tt>.
      # This function delegates the actual addition to the <tt>otus=</tt>, <tt>trees=</tt>, or
      # <tt>otus=</tt> methods.
      # >> doc1 = Bio::NeXML::Parser.new 'test.xml'
      # >> nexml = doc1.parse
      # >> doc1.close
      # >> writer = Bio::NeXML::Writer.new
      # >> writer << nexml.otus
      # >> writer << nexml.trees
      # >> writer << nexml.characters
      def <<( object )
        test = object.instance_of?( Array ) ? object.first : object
        case test
        when Otus
          self.otus = object
        when Trees
          self.trees = object
        when Characters
          self.characters = object
        end
      end
      
      # Write to file.
      # >> writer.save( 'sample.xml', true )
      # ---
      # Arguments:
      # * filename( optional ) - the filename to write to. This need not be given if
      # a filename was provided while initializing Writer.
      # * indent( optional ) - wether to indent the output NeXML. This options assumes
      # <tt>true</tt> by default.
      def save( filename = nil, indent = false )
        filename ||= @filename
        indent ||= @indent
        @doc.save( filename, :indent => indent )
      end

      # Add one or more <em>otus</em> objects to <tt>self</tt>.
      # This function delegates the actual addition to <tt>add_otus</tt> method.
      # >> writer = Bio::NeXML::Writer.new
      # >> writer << nexml.otus
      def otus=( otus )
        if otus.instance_of? Array
          otus.each{ |o| add_otus( o ) }
        else
          add_otus( otus )
        end
      end

      # Add one or more <em>trees</em> objects to <tt>self</tt>.
      # This function delegates the actual addition to <tt>add_trees</tt> method.
      # >> writer = Bio::NeXML::Writer.new
      # >> writer << nexml.trees
      def trees=( trees )
        if trees.instance_of? Array
          trees.each{ |t| add_trees( t ) }
        else
          add_trees( trees )
        end
      end

      # Add one or more <em>characters</em> objects to <tt>self</tt>.
      # This function delegates the actual addition to <tt>add_characters</tt> method.
      # >> writer = Bio::NeXML::Writer.new
      # >> writer << nexml.characters
      def characters=( characters )
        if characters.instance_of? Array
          characters.each{ |c| add_characters( c ) }
        else
          add_characters( characters )
        end
      end
      
      # Add a single <em>otus</em> object to <tt>self</tt>.
      # >> writer = Bio::NeXML::Writer.new
      # >> writer.add_otus( nexml.otus.first )
      def add_otus( otus )
        @root << serialize_otus( otus )
      end

      # Add a single <em>trees</em> object to <tt>self</tt>
      # >> writer = Bio::NeXML::Writer.new
      # >> writer.add_trees( nexml.trees.first )
      def add_trees( trees )
        @root << serialize_trees( trees )
      end

      # Add a single <em>characters</em> object to <tt>self</tt>
      # >> writer = Bio::NeXML::Writer.new
      # >> writer.add_characters( nexml.characters.first )
      def add_characters( characters )
        @root << serialize_characters( characters )
      end

      # Create the root <em>nexml</em> node.
      # >> writer = Bio::NeXML::Writer.new
      # >> writer.root
      def root
        root = create_node( "nexml", :"xsi:schemaLocation" => "http://www.nexml.org/1.0 ../xsd/nexml.xsd", :generator => "bioruby", :version => "0.9" )

        root.namespaces = { nil => "http://www.nexml.org/1.0", :xsi => "http://www.w3.org/2001/XMLSchema-instance", :xlink => "http://www.w3.org/1999/xlink", :nex => "http://www.nexml.org/1.0" }
        root
      end

      def serialize_otu( otu )
        create_node( "otu", attributes( otu, :id, :label ) )
      end

      def serialize_otus( otus )
        node = create_node( "otus", attributes( otus, :id, :label ) )

        otus.each do |otu|
          node << serialize_otu( otu )
        end

        node
      end

      def serialize_trees( trees )
        node = create_node( "trees", attributes( trees, :id, :label, :otus ) )

        trees.each_tree do |tree|
          node << serialize_tree( tree )
        end

        trees.each_network do |network|
          node << serialize_network( network )
        end

        node
      end

      def serialize_characters( characters )
        node = create_node( "characters", attributes( characters, :id, :"xsi:type", :otus, :label ) )

        node << serialize_format( characters.format )
        node << serialize_matrix( characters.matrix )

        node
      end

      def serialize_tree( tree )
        node = create_node( "tree", attributes( tree, :id, :'xsi:type', :label ) )

        tree.each_node do |n|
          node << serialize_node( n )
        end

        rootedge = tree.rootedge
        node << serialize_rootedge( rootedge ) if rootedge

        tree.each_edge do |edge|
          node << serialize_edge( edge )
        end

        node
      end

      def serialize_network( network )
        node = create_node( "network", attributes( network, :id, :'xsi:type', :label ) )

        network.each_node do |n|
          node << serialize_node( n )
        end

        network.each_edge do |edge|
          node << serialize_edge( edge )
        end

        node
      end

      def serialize_node( node )
        create_node( "node", attributes( node, :id, :otu, :root, :label ) )
      end

      def serialize_edge( edge )
        create_node( "edge", attributes( edge, :id, :source, :target, :length, :label ) )
      end

      def serialize_rootedge( rootedge )
        create_node( "rootedge", attributes( rootedge, :id, :target, :length, :label ) )
      end

      def serialize_format( format )
        node = create_node( "format" )

        format.each_states do |states|
          node << serialize_states( states )
        end

        format.each_char do |char|
          node << serialize_char( char )
        end

        node
      end

      def serialize_matrix( matrix )
        node = create_node( "matrix" )

        matrix.each_row do |row|
          case row
          when SeqRow
            node << serialize_seq_row( row )
          when CellRow
            node << serialize_cell_row( row )
          end
        end

        node
      end

      def serialize_seq_row( row )
        node = create_node( "row", attributes( row, :id, :otu, :label ) )
        node << serialize_seq( row.sequences.first )
        node
      end

      def serialize_seq( seq )
        node = create_node( "seq" )
        node << seq.value
        node
      end

      def serialize_cell_row( row )
        node = create_node( "row", attributes( row, :id, :otu, :label ) )

        row.each_cell do |cell|
          node << serialize_cell( cell )
        end

        node
      end

      def serialize_cell( cell )
        create_node( "cell", attributes( cell, :state, :char ) )
      end

      def serialize_states( states )
        node = create_node( "states", attributes( states, :id, :label ) )

        s = states.select{ |state| not state.ambiguous? }
        ps = states.select{ |state| state.ambiguity == :polymorphic }
        us = states.select{ |state| state.ambiguity == :uncertain }

        states_added = []
        s.each do |state|
          states_added << state.id
          node << serialize_state( state )
        end

        temp = []
        ps.each do |state|
          mids = state.collect( &:id )
          if states_added.has?( mids )
            states_added << state.id
            node << serialize_polymorphic_state_set( state )
          else
            temp << state
          end
        end

        temp.each do |state|
          node << serialize_polymorphic_state_set( state )
        end
        temp.clear

        us.each do |state| 
          mids = state.collect( &:id )
          if states_added.has?( mids )
            states_added << state.id
            node << serialize_uncertain_state_set( state )
          else
            temp << state
          end
        end

        temp.each do |state|
            node << serialize_uncertain_state_set( state )
        end
        temp.clear

        node
      end

      def serialize_char( char )
        create_node( "char", attributes( char, :id, :states, :label, :codon ) )
      end

      def serialize_state( state )
        create_node( "state", attributes( state, :id, :label, :symbol ) )
      end

      def serialize_uncertain_state_set( state )
        node = create_node( "uncertain_state_set", attributes( state, :id, :label, :symbol ) )

        state.each_member do |member|
          node << serialize_member( member )
        end

        node
      end

      def serialize_polymorphic_state_set( state )
        node = create_node( "polymorphic_state_set", attributes( state, :id, :label, :symbol ) )

        state.each do |member|
          node << serialize_member( member )
        end

        node
      end

      def serialize_member( member )
        create_node( "member", :state => member.id )
      end

      private

      # Returns a hash of attributes for the given object.
      # See example in unit tests.
      def attributes( object, *names )
        attributes = {}

        names.each do |name|
          case name
          when :id
            attributes[ name ] = object.send( name )
          when :symbol
            # a symbol maybe an integer or a string
            # a length will always be a string
            attributes[ name ] = object.send( name ).to_s
          when :length
            # a length will never be a string
            value = object.send( name )
            attributes[ name ] = value.to_s if value
          when :label
            # a label is optional so the returned value may be nil
            value = object.send( name )
            attributes[ name ] = value if value
          when :"xsi:type"
            attributes[ name ] = object.class.to_s.sub( /Bio::NeXML::/, 'nex:' )
          when :otu, :otus, :states, :source, :target, :char
            # an object is returned but in nexml we need the objects id
            obj = object.send( name )
            attributes[ name ] = obj.id if obj
          when :state
            # a state can be a complex object - use id
            # or a string - use the same value
            obj = object.send( name )
            attributes[ name ] = obj.instance_of?( String ) ? obj : obj.id
          when :root
            value = object.send( :root? )
            attributes[ name ] = value.to_s if value
          end
        end

        attributes
      end

      # Create a XML::Node object with the given name and the attributes.
      # >> writer = Bio::NeXML::Writer.new
      # >> node = writer.send( :create_node, 'nexml', :version => '0.9' )
      # >> node.to_s
      # => "<nexml version=\"0.9\"/>"
      def create_node( name, attributes = {} )
        node = XML::Node.new( name )
        node.attributes = attributes unless attributes.empty?
        node
      end

    end #end class Parser

  end #end module NeXML

end #end module Bio
