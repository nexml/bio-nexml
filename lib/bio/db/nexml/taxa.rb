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
      include Mapper

      property  :id
      property  :label

      belongs_to :otus

      has_n     :nodes

      def initialize( id, options = {}, &block )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
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
      include Enumerable
      include Mapper

      property :id
      property :label

      has_n :otus
      has_n :trees, :singularize => false
      has_n :matrices

      def initialize( id, options = {}, &block )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Returns an array of otu contained in <tt>self</tt>.
      def otus;  end if false   # dummy for rdoc
      # Taken an array of otu and adds it to <tt>self</tt>.
      def otus=; end if false   # dummy for rdoc
      
      # Takes an otu object and appends it to <tt>self</tt>.
      def <<( otu )
        add_otu( otu )
        self
      end

      # Takes an otu or its id and deletes it. Returns the object deleted or <tt>nil</tt>.
      def delete( otu )
        delete_otu( otu )
      end

      # Takes an otu or its id and returns <tt>true</tt> if it is contained in <tt>self</tt>.
      def include?( object )
        has_otu?( object )
      end

      # Returns the otu object with the given id; <tt>nil</tt> if an otu with the given id is not
      # contained in <tt>self</tt>.
      def []( id )
        get_otu_by_id( id )
      end

      # Iterate over each otu in <tt>self</tt> passing it to the block given. If no block is provided,
      # it returns an Enumerator.
      def each( &block )
        @otus.each( &block )
      end

      # Iterate over each otu in <tt>self</tt> passing the otu and its id to the block given. If no
      # block is provided, it returns an Enumerator.
      def each_with_id( &block )
        @otus.each_with_id( &block )
      end

      # Return the number of otu in <tt>self</tt>.
      def length
        number_of_otus
      end

    end #end class Otus
  end
end
