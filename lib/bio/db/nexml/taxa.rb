module Bio
  module NeXML
    # = DESCRIPTION
    # Otu represents a taxon; an implementation of the
    # <em>Taxon</em>[http://nexml.org/nexml/html/doc/schema-1/taxa/taxa/#Taxon] type.
    # An Otu must have an 'id' and may take an an optional 'label'.
    #    >> taxon1 = Bio::NeXML::Otu.new( 'taxon1', 'Label for taxon1' )
    #    >> taxon1.id
    #    => 'taxon1'
    #    >> taxon1.label
    #    => 'Label for taxon1'
    class Otu
      include IDTagged

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

    end #end class Otu

    # = DESCRIPTION
    # Otus is a container for Otu objects; an implementation of the
    # <em>Taxa</em>[http://nexml.org/nexml/html/doc/schema-1/taxa/taxa/#Taxa] type.
    # An Otus must have an 'id' and may take an optional 'label'. Adding two or more Otu objects
    # with the same 'id' to an Otus is not allowed. Doing so will overwrite the previous Otu object
    # with the same the same 'id'.
    #    >> taxa1 = Bio::NeXML::Otus.new( 'taxa1', 'Label for taxa1' )
    #    >> taxa1.id
    #    => 'taxa1'
    #    >> taxa1.label
    #    => 'Label for taxa1'
    #
    #    >> taxon1 = Bio::NeXML::Otu.new( 'taxon1', 'Label for taxon1' )
    #    >> taxon2 = Bio::NeXML::Otu.new( 'taxon2', 'Label for taxon2' )
    #
    #    >> taxa1 << taxon1 << taxon2
    #    >> taxa1.count
    #    => 2
    #    >> taxa1.each { |otu| puts otu.id }
    #    >> taxa1.include?( 'taxon1' )
    #    => true
    #    >> taxa1.delete( 'taxon2' )
    #    >> taxa1.include?( taxon2 )
    #    => false
    class Otus
      include IDTagged
      include Enumerable

      def initialize( id = nil, label = nil, &block )
        @id = id
        @label = label
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      def data
        @data ||= {}
      end
      private :data

      # Returns the otu object with the given id; <tt>nil</tt> if an otu with the given id is not
      # contained in <tt>self</tt>.
      def []( id )
        data[ id ]
      end

      # Takes an otu object and appends it to <tt>self</tt>.
      def <<( otu )
        data[ otu.id ] = otu
        self
      end

      # Takes an otu or its id and deletes it. Returns the object deleted or <tt>nil</tt>.
      def delete( obj )
        id = obj.is_a?( Otu ) ? obj.id : obj
        data.delete( id )
      end

      # Returns an array of otu contained in <tt>self</tt>.
      def otus
        data.values
      end

      # Taken an array of otu and adds it to <tt>self</tt>.
      def otus=( otus )
        otus.each { |otu| self << otu }
      end

      # Iterate over each otu in <tt>self</tt> passing it to the block given. If no block is provided,
      # it returns an Enumerator.
      def each( &block ) # :yield: otu
        data.each_value( &block )
      end

      # Iterate over each otu in <tt>self</tt> passing the otu and its id to the block given. If no
      # block is provided, it returns an Enumerator.
      def each_with_id( &block ) # :yield: id, otu
        data.each( &block )
      end

      # Return the number of otu contained in <tt>self</tt>.
      def length
        data.length
      end
      alias count length

      # Takes an otu or its id and returns <tt>true</tt> if it is contained in <tt>self</tt>.
      def include?( obj )
        obj.is_a?( Otu ) ? data[ obj.id ] == obj : data.has_key?( obj )
      end
      alias has? include?

    end #end class Otus
  end
end
