module Bio
  module NeXML
    # State defines a possible observation with its 'symbol' attribute. A state may be ambiguous. An
    # ambiguous state must define an ambiguity mapping which may be 'polymorphic', resolved in an
    # 'and' context, or uncertain, resolved in a 'or' context.
    #
    #    state = Bio::NeXML::State.new( 'state1', :label => 'A label' )
    #    state.id            #=> 'state1'
    #    state.label         #=> 'A label'
    #    state.ambiguous?    #=> true
    #    state.ambiguity     #=> :polymorphic
    class State
      include Enumerable
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      # A file level unique identifier.
      attr_accessor :id

      # Observation for this state.
      attr_reader :symbol

      # Polymorphic or uncertain.
      attr_accessor :ambiguity

      # A human readable description of the state.
      attr_accessor :label

      # Each state is contained in a states element.
      belongs_to :states

      # Refer to the polymorphic or uncertain state that it belongs to.
      belongs_to :state_set, :update => :member

      # A polymorphic or uncertain state will have one or more members.
      has_n :members, :index => false, :update => :state_set

      has_n :cells, :index => false

      def initialize( id, symbol = nil, options = {}, &block )
        @id = id
        symbol.is_a?( Hash ) ? options = symbol : self.symbol = symbol
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      def symbol=( symbol )
        @symbol = symbol
      end

      # Takes a Bio::NeXML::State object and adds it to the ambiguity mapping of the state. 
      # Returns # <tt>self</tt>.
      def add_member( member ); end if false

      def ambiguous?
        !!ambiguity
      end
      
      def polymorphic?
        ambiguity == :polymorphic
      end
      
      def uncertain?
        ambiguity == :uncertain
      end

      def include?( member )
        has_member?( member )
      end

      def count
        number_of_members
      end
      alias length count
      
      # Iterate over each member in <tt>self</tt> passing it to the block given. If no block is provided,
      # it returns an Enumerator.
      def each( &block )
        @members.each( &block )
      end        

      def to_str
        symbol.to_s
      end
      alias to_s to_str
      
      def to_xml
        tagname = nil
        if ambiguity == :polymorphic
          tagname = "polymorphic_state_set"
        elsif ambiguity == :uncertain
          tagname = "uncertain_state_set"
        else
          tagname = "state"
        end
        node = @@writer.create_node( tagname, @@writer.attributes( self, :id, :label, :symbol ) )
        if count > 0
          self.each_member do |member|
            node << @@writer.create_node( "member", :state => member.id )
          end
        end
        node
      end              

      class << self
        def polymorphic( id, symbol = nil, options = {}, &block )
          state = new( id, symbol, options, &block )
          state.ambiguity = :polymorphic
          state
        end

        def uncertain( id, symbol = nil, options = {}, &block )
          state = new( id, symbol, options, &block )
          state.ambiguity = :uncertain
          state
        end
      end
    end #end class State

    # A char specifies which states apply to matrix columns.
    class Char
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      # A file level unique identifier.
      attr_accessor :id

      # A human readable description.
      attr_accessor :label

      # Each char links to a states as a means of describing possible observations for that
      # particular column.
      belongs_to :format
      belongs_to :states

      has_n :cells, :index => false
      
      def initialize( id, states = nil, options = {} )
        @id = id
        unless states.nil?
          states.is_a?( Hash ) ? options = states : self.states = states
        end
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end
      
      def to_xml
        @@writer.create_node( "char", @@writer.attributes( self, :id, :states, :label, :codon ) )
      end      
    end

    class States
      include Enumerable
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      # A file level unique identifier.
      attr_accessor    :id

      # A human readable description of the state.
      attr_accessor    :label

      belongs_to :format

      # Possible observation states.
      has_n       :states

      # Matrix columns linked to this states.
      has_n       :chars

      def initialize( id, options = {} )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end
      
      def add_state( state ); end if false # dummy for rdoc
      
      def delete_state( state ); end if false # dummy for rdoc

      def has_state?( state ); end if false # dummy for rdoc

      def get_state_by_id( state ); end if false # dummy for rdoc

      def each_state( state ); end if false # dummy for rdoc

      def each_char( state ); end if false # dummy for rdoc

      def include?( state )
        has_state?( state )
      end
      
      # Iterate over each state set in <tt>self</tt> passing it to the block given. If no block is provided,
      # it returns an Enumerator.
      def each( &block )
        @states.each( &block )
      end
      
      def to_xml
        node = @@writer.create_node( "states", @@writer.attributes( self, :id, :label ) )
        self.each_state do |state|
          node << state.to_xml
        end
        node
      end      
    end
    
    class Format
      @@writer = Bio::NeXML::Writer.new
      include Mapper     
      
      # A format block must define set(s) of possible observation states.
      has_n :states, :singularize => false
      
      # A format will have one or more columns( chars => columns ),
      has_n :chars
      
      # Because format elements don't have id attributes, we will use
      # object_id in this case
      attr_accessor :id
      
      def initialize( options = {} )
        @id = self.object_id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end      
      
      def add_states( states )
        # dummy for rdoc
      end if false
      
      # Returns true if the given state set( Bio::NeXML::States object ) is
      # defined for the format block.
      def has_states?( states )
        # dummy for rdoc
      end if false
      
      # Remove a state set from the format.
      # * Arguments :
      # states( required ) - a Bio::NeXML::State object.
      # * Returns : the deleted object.
      #    format.delete_states( states )
      #    format.states                #=> [ .. .. ]
      #    states.format                #=> nil
      def delete_states( states )
        # dummy for rdoc
      end if false
      
      # Fetch a state set( Bio::NeXML::States object ) by id. Returns <tt>nil</tt> if none found.
      def get_states_by_id( id )
        # dummy for rdoc
      end if false
      
      # Returns the number of state sets defined for the matrix.
      def number_of_states
        # dummy for rdoc
      end if false
      
      # Add a column definition to the format.
      # * Arguments :
      # char( required ) - a Bio::NeXML::Char object.
      # * Returns : <tt>self</tt>.
      #    format.add_char( char )
      #    format.chars               #=> [ .. char .. ]
      #    char.format                #=> format
      def add_char( char )
        # dummy for rdoc
      end if false
      
      # Remove a column definition from the matrix.
      # * Arguments :
      # char( required ) - a Bio::NeXML::Char object.
      # * Returns : the deleted object.
      #    matrix.delete_char( char )
      #    matrix.chars               #=> [ .. .. ]
      #    char.matrix                #=> nil
      def delete_char( char )
        # dummy for rdoc
      end if false
      
      # Returns an array of state sets( Bio::NeXML::States objects ) for the matrix.
      #    matrix.states  #=> [ .. .. ]
      def states
        # dummy for rdoc
      end if false
      
      # Returns an array of column definitions( Bio::NeXML::Char objects ) for the matrix.
      #    matrix.chars  #=> [ .. .. ]
      def chars
        # dummy for rdoc
      end if false
      
      # Add state sets to the matrix. This function will overwrite previous state set definitions
      # for the matrix if any.
      # * Arguments :
      # states( required ) - an array of Bio::NeXML::States object.
      #    matrix.states = [ states ]
      #    matrix.states    #=> [ states ]
      #    states.matrix    #=> matrix
      def states=( states )
        # dummy for rdoc
      end if false
      
      # Add column definitions to the matrix. This function will override the previous column
      # definitions if any.
      # * Arguments :
      # chars( required ) - an array of Bio::NeXML::Char object.
      #    matrix.chars = [ char ]
      #    matrix.chars    #=> [ char ]
      #    char.matrix     #=> matrix
      def chars=( chars )
        # dummy for rdoc
      end if false
      
      # Fetch a state set( Bio::NeXML::States object ) by id. Returns <tt>nil</tt> if none found.
      def get_states_by_id( id )
        # dummy for rdoc
      end if false
      
      # Fetch a column definition( Bio::NeXML::Char object ) by id. Returns <tt>nil</tt> if none
      # found.
      def get_char_by_id( id )
        # dummy for rdoc
      end if false      
      
      # Returns true if the given state set( Bio::NeXML::States object ) is defined for the matrix.
      def has_states?( states )
        # dummy for rdoc
      end if false
      
      # Returns true if the given column definition( Bio::NeXML::Char object ) is defined for the matrix.
      def has_char?( char )
        # dummy for rdoc
      end if false      
      
      # Iterate over each state sets( Bio::NeXML::States object ) defined for the matrix. Returns an
      # Enumerator if no block is provided.
      def each_states
        # dummy for rdoc
      end if false
      
      # Iterate over each column definitions( Bio::NeXML::Char object ) defined for the matrix. Returns
      # an Enumerator if no block is provided.
      def each_char
        # dummy for rdoc
      end if false      
      
      # Returns the number of state sets defined for the matrix.
      def number_of_states
        # dummy for rdoc
      end if false
      
      # Returns the number of column definitions defined for the matrix.
      def number_of_chars
        # dummy for rdoc
      end if false      
      
      def to_xml
        node = @@writer.create_node( "format" )

        self.each_states do |states|
          node << states.to_xml
        end

        self.each_char do |char|
          node << char.to_xml
        end

        node
      end
      
    end # end of format

    # Cell is the smallest unit of a character state matrix or of a sequence. A cell maybe bound or
    # unbound. If a cell points to a char and has a state, it is a bound cell. Bound cells correspond
    # to the cell tag of NeXML. Value of a bound cell is the same as the 'symbol' of the state it points
    # to. Value of a bound cell may be changed by assigning a different state to it. An unbound cell
    # holds a raw value.
    #    cell = Bio::NeXML::Cell.new( 'A' )
    #    cell.bound?           #=> false
    #    cell.value            #=> 'A'
    #
    #    # Assign a new value to an unbound cell.
    #    cell.value = 'B'
    #    cell.value            #=> 'B'
    #
    #    cell = Bio::NeXML::Cell.new( :char => char1, :state => stateA )
    #    cell.bound?           #=> true
    #    cell.value            #=> 'A'
    #
    #    # Can not assign a value to a bound cell directly.
    #    cell.value = 'B'
    #    cell.value            #=> 'A'
    #
    #    # Changing the state of a bound cell changes its value.
    #    cell.state = stateB
    #    cell.value            #=> 'B'
    class Cell
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      attr_accessor :char
      attr_accessor :state
      attr_accessor :label

      belongs_to :state
      belongs_to :char
            
      belongs_to :cellrow
      alias row cellrow

      def initialize( char = nil, state = nil, options = {} )
        case char
        when Hash
          properties( char )
        when Char
          self.char = char
        else
          @value = char unless char.nil?
        end

        case state
        when State
          self.state = state
        when Hash
          properties( state )
        end

        properties( options ) unless options.nil?
      end

      # Return the value of a cell.
      def value
        bound? ? state.symbol : @value
      end
      alias symbol value

      def value=( value )
        bound? ? nil : @value = value
      end

      def bound?
        !!( char and state )
      end

      # Allow cells to be implicitly used as a String.
      def to_str
        value.to_s
      end
      alias to_s to_str
      
      def to_xml
        @@writer.create_node( "cell", @@writer.attributes( self, :state, :char ) )
      end
      
    end
    
    class ContinuousCell < Cell
      def value
        @value
      end
      def value=( value )
        @value = value
      end
      def state=( value )
        @value = value
      end
      alias symbol value
      alias state value
    end

    class Sequence
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      # Every sequence belongs to a row
      belongs_to :seqrow
      alias row seqrow

      attr_accessor :value
      
      # Because seq elements don't have id attributes, we will use
      # object_id in this case
      attr_accessor :id

      def initialize( options = {} )
        properties( options ) unless options.empty?
        @id = self.object_id
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      def type
        return nil if cells.empty?
        cells.first.bound? ? :granular : :raw
      end

      def each_value( &block ) # :yields: value
        if block_given?
          cells.each { |c| yield c.value }
        else
          enum_for( :each_value )
        end
      end
      
      def to_xml
        node = @@writer.create_node( "seq" )
        node << self.value
        node
      end
      
    end
    
    class Matrix
      @@writer = Bio::NeXML::Writer.new
      include Mapper
      has_n :rows
      belongs_to :characters     
      
      # Because matrix elements don't have id attributes, we will use
      # object_id in this case
      attr_accessor :id
      
      def initialize()
        @id = self.object_id
      end
      
      def add_row( row )
        # dummy for rdoc
      end if false
      
      # Returns true if the given row ( Bio::NeXML::Row object ) is
      # defined for the matrix block.
      def has_rows?( rows )
        # dummy for rdoc
      end if false
      
      # Remove a row from the matrix.
      # * Arguments :
      # row( required ) - a Bio::NeXML::Row object.
      # * Returns : the deleted object.
      #    matrix.delete_row( row )
      #    matrix.rows                #=> [ .. .. ]
      #    row.matrix                #=> nil
      def delete_row( row )
        # dummy for rdoc
      end if false
      
      # Fetch a row ( Bio::NeXML::Row object ) by id. Returns <tt>nil</tt> if none found.
      def get_row_by_id( id )
        # dummy for rdoc
      end if false
      
      # Returns the number of rows defined for the matrix.
      def number_of_rows
        # dummy for rdoc
      end if false
      
      
      # Returns an array of rows( Bio::NeXML::Rows objects ) for the matrix.
      #    matrix.rows  #=> [ .. .. ]
      def rows
        # dummy for rdoc
      end if false
      
      # Add rowsthe matrix. This function will overwrite previous rows
      # for the matrix if any.
      # * Arguments :
      # rows( required ) - an array of Bio::NeXML::Row object.
      #    matrix.rows = [ rows ]
      #    matrix.rows    #=> [ rows ]
      #    rows.matrix    #=> matrix
      def rows=( rows )
        # dummy for rdoc
      end if false     
      
      # Returns true if the given row( Bio::NeXML::Row object ) is defined for the matrix.
      def has_row?( rows )
        # dummy for rdoc
      end if false     
      
      # Iterate over each row ( Bio::NeXML::Row object ) defined for the matrix. Returns an
      # Enumerator if no block is provided.
      def each_row
        # dummy for rdoc
      end if false    
      
      # Returns the number of rows defined for the matrix.
      def number_of_rows
        # dummy for rdoc
      end if false
      
      def to_xml
        node = @@writer.create_node( "matrix" )

        self.each_row do |row|
          node << row.to_xml
        end

        node
      end      
      
    end
    
    class SeqMatrix < Matrix
    end
    class CellMatrix < Matrix
    end
    class Row
      include Mapper     

      # A file level unique identifier.
      attr_accessor :id

      # A human readable description.
      attr_accessor :label

      # Every row refers to a taxon.
      belongs_to :otu
      belongs_to :matrix      

      def initialize( id, options = {} )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end
           
    end # end of row class
    class SeqRow < Row
      @@writer = Bio::NeXML::Writer.new
      # actually, probably only one <seq/> element
      has_n :sequences
      # Below are methods stubs to be picked up by rdoc, as these methods are generated dynamically.

      # Add a sequence( row ) to the matrix.
      # * Arguments :
      # sequence( required ) - a Bio::NeXML::Sequence object.
      # * Returns : <tt>self</tt>.
      #    matrix.add_matrix( sequence )
      #    matrix.sequences               #=> [ .. sequence .. ]
      #    sequence.matrix                #=> matrix
      def add_sequence( sequence )
        # dummy for rdoc
      end if false

      # Remove a sequence( row ) from the matrix.
      # * Arguments :
      # sequence( required ) - a Bio::NeXML::Sequence object.
      # * Returns : the deleted object.
      #    matrix.delete_sequence( sequence )
      #    matrix.sequences               #=> [ .. .. ]
      #    sequence.matrix                #=> nil
      def delete_sequence( sequence )
        # dummy for rdoc
      end if false

      # Returns an array of sequences ( Bio::NeXML::Sequence objects ) for the matrix.
      #    matrix.sequences  #=> [ .. .. ]
      def sequences
        # dummy for rdoc
      end if false

      # Add sequences to the matirx. This function will override previous sequences if any.
      # * Arguments :
      # sequences( required ) - an array of Bio::NeXML::Sequence object.
      #    matrix.sequences = [ sequence ]
      #    matrix.sequences    #=> [ sequence ]
      #    sequence.matrix     #=> matrix
      def sequences=( sequences )
        # dummy for rdoc
      end if false

      # Returns true if the given sequence( Bio::NeXML::Sequence object ) is defined for the matrix.
      def has_sequence?( sequence )
        # dummy for rdoc
      end if false

      # Iterate over each sequence ( Bio::NeXML::Sequence object ) defined for the matrix. Returns
      # an Enumerator if no block is provided.
      def each_sequence
        # dummy for rdoc
      end if false

      # Returns the number of sequences defined for the matrix.
      def number_of_sequences
        # dummy for rdoc
      end if false

      def to_xml
        node = @@writer.create_node( "row", @@writer.attributes( self, :id, :otu, :label ) )
        node << self.sequences.first.to_xml
        node
      end      
      
    end
    class CellRow < Row
      @@writer = Bio::NeXML::Writer.new
      has_n :cells, :index => false
      # Add a cell to the row
      # * Arguments :
      # cell( required ) - a Bio::NeXML::Cell object.
      # * Returns : <tt>self</tt>.
      #    row.add_cell( cell )
      #    row.cells               #=> [ .. cell .. ]
      #    cell.row                #=> row
      def add_cell( cell )
        # dummy for rdoc
      end if false

      # Remove a cell from the row
      # * Arguments :
      # cell( required ) - a Bio::NeXML::Cell object.
      # * Returns : the deleted object.
      #    row.delete_cell( cell )
      #    row.cells               #=> [ .. .. ]
      #    cell.row                #=> nil
      def delete_cell( cell )
        # dummy for rdoc
      end if false

      # Returns an array of cells ( Bio::NeXML::Cell objects ) for the row.
      #    matrix.cells  #=> [ .. .. ]
      def cells
        # dummy for rdoc
      end if false

      # Add cells to the row. This function will override previous cells if any.
      # * Arguments :
      # cells( required ) - an array of Bio::NeXML::Cell object.
      #    row.cells = [ cells ]
      #    row.cells    #=> [ cells ]
      #    cell.row     #=> row
      def cells=( cells )
        # dummy for rdoc
      end if false

      # Returns true if the given cell( Bio::NeXML::Cell object ) is defined for the row.
      def has_cell?( cell )
        # dummy for rdoc
      end if false

      # Iterate over each cell ( Bio::NeXML::Cell object ) defined for the row. Returns
      # an Enumerator if no block is provided.
      def each_cell
        # dummy for rdoc
      end if false

      # Returns the number of cells defined for the row.
      def number_of_cells
        # dummy for rdoc
      end if false
      
      def to_xml
        node = @@writer.create_node( "row", @@writer.attributes( self, :id, :otu, :label ) )

        self.each_cell do |cell|
          node << cell.to_xml
        end

        node
      end      
      
    end

    # A character state matrix. This class is analogous to the characters element of NeXML.
    class Characters
      include Mapper
      @@writer = Bio::NeXML::Writer.new

      # An id should be uniquely scoped in an NeXML file. It need not be unique globally. It is a
      # compulsory attribute.
      attr_accessor      :id
      
      # A characters block holds a single format definition
      attr_accessor      :format
      
      # A characters block holds a single matrix definition
      attr_accessor      :matrix

      # A human readable description. Its usage is optional.
      attr_accessor      :label

      belongs_to         :nexml

      # Every characters block compulsorily links to a taxa block( otus ).
      belongs_to         :otus

      def initialize( id, options = {} )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end
      
      def add_format( format )
        format = format
      end
      
      def add_matrix( matrix )
        matrix = matrix
      end
      
      def to_xml
        node = @@writer.create_node( "characters", @@writer.attributes( self, :id, :"xsi:type", :otus, :label ) )

        node << self.format.to_xml
        node << self.matrix.to_xml

        node
      end      

    end #end class Characters
    class Dna < Characters
    end
    class DnaSeqs < Dna
    end
    class DnaCells < Dna
    end
    class Rna < Characters
    end
    class RnaSeqs < Rna
    end
    class RnaCells < Rna
    end
    class Protein < Characters
    end
    class ProteinSeqs < Protein
    end
    class ProteinCells < Protein
    end
    class Standard < Characters
    end
    class StandardSeqs < Standard
    end
    class StandardCells < Standard
    end
    class Restriction < Characters
    end
    class RestrictionSeqs < Restriction
    end
    class RestrictionCells < Restriction
    end
    class Continuous < Characters
    end
    class ContinuousSeqs < Continuous
    end
    class ContinuousCells < Continuous
    end
  end
end
