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
      include Mapper

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

      def to_str
        symbol.to_s
      end
      alias to_s to_str

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

      # A file level unique identifier.
      attr_accessor :id

      # A human readable description.
      attr_accessor :label

      # Each char links to a states as a means of describing possible observations for that
      # particular column.
      belongs_to :matrix
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
    end

    class States
      include Mapper

      # A file level unique identifier.
      attr_accessor    :id

      # A human readable description of the state.
      attr_accessor    :label

      belongs_to :matrix

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
    end

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

      attr_accessor :char
      attr_accessor :state
      attr_accessor :label

      belongs_to :sequence
      belongs_to :state
      belongs_to :char

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
    end

    class Sequence
      include Mapper

      # A file level unique identifier.
      attr_accessor :id

      # A human readable description.
      attr_accessor :label

      # Every row refers to a taxon.
      belongs_to :otu
      belongs_to :matrix

      has_n :cells, :index => false

      def initialize( id, options = {} )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      def raw
        cells.join
      end

      def raw=( value )
        cells = value.each_char.map { |c| Cell.new( c ) }
        self.cells = cells
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
    end

    # A character state matrix. This class is analogous to the characters element of NeXML.
    class Matrix
      include Mapper

      @@types = [ :DnaSeqs,            :DnaCells,
                  :RnaSeqs,            :RnaCells,
                  :ProteinSeqs,        :ProteinCells,
                  :StandardSeqs,       :StandardCells,
                  :ContinuousSeqs,     :ContinuousCells,
                  :RestrictionSeqs,    :RestrictionState
                ]

      # An id should be uniquely scoped in an NeXML file. It need not be unique globally. It is a
      # compulsory attribute.
      attr_accessor      :id

      # A human readable description. Its usage is optional.
      attr_accessor      :label

      # Type of the matrix. Used only when dealing with 'xsi:type' attribute of the characters element.
      # This attribute, though optional, must be set to generate valid NeXML.
      attr_reader        :type

      belongs_to         :nexml

      # Every matrix compulsorily links to a taxa block( otus ).
      belongs_to         :otus

      # A matrix must define set(s) of possible observation states.
      has_n              :states, :singularize => false

      # Obviously, a matrix will have one or more columns( chars => columns ),
      has_n              :chars

      # and, one or more rows( sequences => rows ).
      has_n              :sequences

      def initialize( id, options = {} )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Set the type of the matrix.
      # * Arguments :
      # type( required ) - one of the following :dna, :rna, :aa, :standard, :continuous, :restriction
      # * Raises :
      # "RuntimeError: Unkown type", if an unknown type is given.
      def type=( type )
        type = type.to_sym
        raise "Unknown type" unless @@types.include?( type )
        @type = type
      end

      # Below are methods stubs to be picked up by rdoc, as these methods are generated dynamically.
      
      # Add a set of states to the matrix. 
      # * Arguments :
      # states( required ) - a Bio::NeXML::State object.
      # * Returns : <tt>self</tt>.
      #    matrix.add_states( states )
      #    matrix.states                #=> [ .. states .. ]
      #    states.matrix                #=> matrix
      def add_states( states )
        # dummy for rdoc
      end if false

      # Add a column definition to the matrix.
      # * Arguments :
      # char( required ) - a Bio::NeXML::Char object.
      # * Returns : <tt>self</tt>.
      #    matrix.add_char( char )
      #    matrix.chars               #=> [ .. char .. ]
      #    char.matrix                #=> matrix
      def add_char( char )
        # dummy for rdoc
      end if false

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

      # Remove a state set from the matrix.
      # * Arguments :
      # states( required ) - a Bio::NeXML::State object.
      # * Returns : the deleted object.
      #    matrix.delete_states( states )
      #    matrix.states                #=> [ .. .. ]
      #    states.matrix                #=> nil
      def delete_states( states )
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

      # Returns an array of sequences ( Bio::NeXML::Sequence objects ) for the matrix.
      #    matrix.sequences  #=> [ .. .. ]
      def sequences
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

      # Add sequences to the matirx. This function will override previous sequences if any.
      # * Arguments :
      # sequences( required ) - an array of Bio::NeXML::Sequence object.
      #    matrix.sequences = [ sequence ]
      #    matrix.sequences    #=> [ sequence ]
      #    sequence.matrix     #=> matrix
      def sequences=( sequences )
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

      # Fetch a sequence( Bio::NeXML::Sequence object ) by id. Returns <tt>nil</tt> if none found.
      def get_sequence_by_id( id )
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

      # Returns true if the given sequence( Bio::NeXML::Sequence object ) is defined for the matrix.
      def has_sequence?( sequence )
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

      # Iterate over each sequence ( Bio::NeXML::Sequence object ) defined for the matrix. Returns
      # an Enumerator if no block is provided.
      def each_sequence
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

      # Returns the number of sequences defined for the matrix.
      def number_of_sequences
        # dummy for rdoc
      end if false
    end #end class Matrix
  end
end
