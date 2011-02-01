module Bio
  module NeXML
    class TestState < Test::Unit::TestCase
      def setup
        @state = Bio::NeXML::State.new( 'stateA', 'A' )
      end

      def test_new1
        # if one argument given use it as id
        s = Bio::NeXML::State.new( 'stateA' )
        assert_equal 'stateA', s.id
      end

      def test_new2
        # if two argument given use them as id and sybmol respectively
        s = Bio::NeXML::State.new( 'stateA', 'A' )
        assert_equal 'stateA', s.id
        assert_equal 'A', s.symbol
      end

      def test_new3
        # options hash as third argument
        # preferred
        s = Bio::NeXML::State.new( 'stateA', 'A', :label => 'A label' )
        assert_equal 'stateA', s.id
        assert_equal 'A', s.symbol
        assert_equal 'A label', s.label
      end

      def test_new4
        # options hash as second argument
        s = Bio::NeXML::State.new( 'stateA', :symbol => 'A', :label => 'A label' )
        assert_equal 'stateA', s.id
        assert_equal 'A', s.symbol
        assert_equal 'A label', s.label
      end

      def test_id
        @state.id = 'state1'
        assert_equal 'state1', @state.id
      end

      def test_symbol
        @state.symbol = 1
        assert_equal 1, @state.symbol
      end

      def test_label
        @state.label = 'State'
        assert_equal 'State', @state.label
      end

      def test_ambiguous
        assert !@state.ambiguous?
      end

      def test_ambiguity
        assert_nil @state.ambiguity
      end

      def test_to_str
        assert_equal 'A', @state.to_str
      end
    end

    class TestAmbiguousState < TestState
      def setup
        @members = [
          %w|s1 A|,
          %w|s2 B|,
          %w|s3 C|,
          %w|s4 D|,
          %w|s5 E|
        ].map { | pair | Bio::NeXML::State.new( *pair ) }

        @state = Bio::NeXML::State.uncertain( 'state1', '?' )
        @state.members = @members
      end

      def test_new5
        s = Bio::NeXML::State.new( 'stateA', 'A', :ambiguity => :polymorphic )
        assert s.ambiguous?
        assert_equal :polymorphic, s.ambiguity
      end

      def test_new6
        s = Bio::NeXML::State.new( 'stateA', 'A', :ambiguity => :uncertain, :members => @members )
        assert_equal @members, s.members
      end

      def test_uncertain
        s = Bio::NeXML::State.uncertain( 'stateA', 'A', :members => @members )
        assert s.ambiguous?
        assert_equal :uncertain, s.ambiguity
        assert_equal @members, s.members
      end

      def test_polymorphic
        s = Bio::NeXML::State.polymorphic( 'stateA', 'A', :members => @members )
        assert s.ambiguous?
        assert_equal :polymorphic, s.ambiguity
        assert_equal @members, s.members
      end

      def test_ambiguous
        assert @state.ambiguous?
      end

      def test_ambiguity
        assert_equal :uncertain, @state.ambiguity
      end

      def test_add_member
        s = Bio::NeXML::State.new( 's6', 'F' )
        @state.add_member( s )
        assert @state.has_member?( s )
        assert_equal @state, s.state_set
      end

      def test_delete_member
        s = @members[ 0 ]
        assert_equal( s, @state.delete_member( s ) )
        assert_nil s.state_set
      end

      def test_members
        s = @members[ 0 ]
        @state.members = [ s ]
        assert_equal [ s ], @state.members
        assert_equal @state, s.state_set
      end

      def test_include
        assert @state.include?( @members[ 0 ] )
      end
      
      def test_count
        assert_equal @members.length, @state.count
      end

      def test_each
      end

      def test_each_with_symbol
      end

      def test_to_str
        assert_equal '?', @state.to_str
      end
    end #end class TestAmbiguousState

    class TestChar < Test::Unit::TestCase
      def setup
        @states = Bio::NeXML::States.new( 'states' )
        @char = Bio::NeXML::Char.new( 'char1' )
      end

      def test_new1
        # if one argument given use it as id
        c = Bio::NeXML::Char.new( 'char1' )
        assert_equal 'char1', c.id
      end

      def test_new2
        # if two arguments given use the second as states
        c = Bio::NeXML::Char.new( 'char1', @states )
        assert_equal 'char1', c.id
        assert_equal @states, c.states
      end

      def test_new3
        # 3rd argument as optional hash
        c = Bio::NeXML::Char.new( 'char1', @states, :label => 'A label' )
        assert_equal 'char1', c.id
        assert_equal @states, c.states
        assert_equal 'A label', c.label
      end

      def test_new4
        # 2nd argument as optional hash
        c = Bio::NeXML::Char.new( 'char1', :states => @states, :label => 'A label' )
        assert_equal 'char1', c.id
        assert_equal @states, c.states
        assert_equal 'A label', c.label
      end

      def test_id
        @char.id = 'char2'
        assert_equal 'char2', @char.id
      end

      def test_label
        @char.label = 'A label'
        assert_equal 'A label', @char.label
      end

      def test_states
        @char.states = @states
        assert_equal @states, @char.states
        assert @states.has_char?( @char )
      end

      def test_cells
        cell = Bio::NeXML::Cell.new( @char )
        assert_equal [ cell ], @char.cells
      end
    end

    class TestStates < Test::Unit::TestCase
      def setup
        @ss = [
          %w|s1 A|,
          %w|s2 B|,
          %w|s3 C|,
          %w|s4 D|,
          %w|s5 E|
        ].map { | pair | Bio::NeXML::State.new( *pair ) }
        @states = Bio::NeXML::States.new( 'states', :states => @ss )
      end

      def test_new1
        # one argument => id
        states = Bio::NeXML::States.new( 'states' )
        assert_equal 'states', states.id
      end

      def test_new2
        # second argument => optional hash
        states = Bio::NeXML::States.new( 'states', :label => 'state container' )
        assert_equal 'states', states.id
        assert_equal 'state container', states.label
      end

      def test_id
        @states.id = 'states1'
        assert_equal 'states1', @states.id
      end

      def test_label
        @states.label = 'a label'
        assert_equal 'a label', @states.label
      end

      def test_add_state
        s = Bio::NeXML::State.new( 's6', 'F' )
        @states.add_state( s )
        assert @states.include?( s )
        assert_equal @states, s.states
      end

      def test_delete_state
        s = @ss[ 0 ]
        assert_equal s, @states.delete_state( s )
        assert_nil s.states
      end

      def test_states
        s = @ss[ 0 ]
        @states.states = [ s ]
        assert_equal [ s ], @states.states
        assert_equal @states, s.states
      end

      def test_get_state_by_id
        s = @ss[ 0 ]
        assert_equal s, @states.get_state_by_id( s.id )
      end

      def test_has_state
        assert @states.has_state?( @ss[ 0 ] )
      end

      def test_chars
        char = Bio::NeXML::Char.new( 'char', @states )
        assert_equal @states, char.states
        assert_equal [ char ], @states.chars
      end
    end

    class TestCell_new < Test::Unit::TestCase
      # test Bio::NeXML::Cell.new as a cell can be initialized in mulitple ways
      # depending on type( bound/ unbound ) and need.

      def test_new1
        # unbound cell, no options
        cell = Bio::NeXML::Cell.new( 'A' )
        assert_equal 'A', cell.value
      end

      def test_new2
        # unbound cell, with options
        cell = Bio::NeXML::Cell.new( 'A', :label => 'label' )
        assert_equal 'A', cell.value
        assert_equal 'label', cell.label
      end

      def test_new3
        # bound cell, no options
        ch = Bio::NeXML::Char.new( 'ch' )
        s = Bio::NeXML::State.new( 'ss' )
        cell = Bio::NeXML::Cell.new( ch, s )
        assert_equal ch, cell.char
        assert_equal s, cell.state
      end

      def test_new4
        # bound cell, with options
        ch = Bio::NeXML::Char.new( 'ch' )
        s = Bio::NeXML::State.new( 'ss' )
        cell = Bio::NeXML::Cell.new( ch, s, :label => 'label' )
        assert_equal ch, cell.char
        assert_equal s, cell.state
        assert_equal 'label', cell.label
      end

      def test_new5
        # all keyword args
        ch = Bio::NeXML::Char.new( 'ch' )
        s = Bio::NeXML::State.new( 'ss' )
        cell = Bio::NeXML::Cell.new( :char => ch, :state => s, :label => 'label' )
        assert_equal ch, cell.char
        assert_equal s, cell.state
        assert_equal 'label', cell.label
      end
    end

    class TestUnboundCell < Test::Unit::TestCase
      def setup
        @cell = Bio::NeXML::Cell.new( 'A', :label => 'label' )
      end

      def test_state
        assert_nil @cell.state
      end

      def test_char
        assert_nil @cell.char
      end

      def test_bound
        assert !@cell.bound?
      end

      def test_value
        @cell.value = 'B'
        assert_equal 'B', @cell.value
      end
    end

    class TestBoundCell < Test::Unit::TestCase
      def setup
        @stateA = Bio::NeXML::State.new( 'stateA', 'A' )
        @char = Bio::NeXML::Char.new( 'char' )
        @cell = Bio::NeXML::Cell.new( :char => @char, :state => @stateA )
      end

      def test_state
        s = Bio::NeXML::State.new( 'stateB', 'B' )
        @cell.state = s
        assert_equal s, @cell.state
      end

      def test_char
        c = Bio::NeXML::Char.new( 'ch' )
        @cell.char = c
        assert_equal c, @cell.char
      end

      def test_value
        assert_equal @stateA.symbol, @cell.value
        @cell.value = 'B'
        assert_not_equal 'B', @cell.value # since it is a bound cell
        @stateA.symbol = 'B'
        assert_equal 'B', @cell.value # a bound cell reflects the value of its state
      end
    end

    class TestRow < Test::Unit::TestCase
      def setup
        @row = Bio::NeXML::Row.new( 'seq' )
      end

      def test_id
        @row.id = 'seq1'
        assert_equal 'seq1', @row.id
      end

      def test_label
        @row.label = 'a sequence'
        assert_equal 'a sequence', @row.label
      end

      def test_otu
        otu = Bio::NeXML::Otu.new( 'otu' )
        @row.otu = otu
        assert_equal otu, @row.otu
        assert_equal [ @row ], otu.rows
      end
    end

    class TestMatrix < Test::Unit::TestCase
      def setup
        @ss = [
          %w|s1 A|,
          %w|s2 B|,
          %w|s3 C|,
          %w|s4 D|,
          %w|s5 E|
        ].map { | pair | Bio::NeXML::State.new( *pair ) }
        @states = Bio::NeXML::States.new( 'states', :states => @ss )

        @char1 = Bio::NeXML::Char.new( 'char1', :states => @states )
        @char2 = Bio::NeXML::Char.new( 'char2', :states => @states )

        @sequence = Bio::NeXML::Sequence.new( :value => 'ABCDE' )
        @row = Bio::NeXML::Row.new( 'row1' )
        @matrix = Bio::NeXML::Characters.new( 'matrix1' )
        @format = Bio::NeXML::Format.new
        @format.add_states( @states )
        @format.chars = [ @char1, @char2 ]
        @row.add_sequence( @sequence )
      end

      def test_id
        @matrix.id = 'id'
        assert_equal 'id', @matrix.id
      end

      def test_label
        @matrix.label = 'label'
        assert_equal 'label', @matrix.label
      end

      def test_type
        @matrix.type = :DnaSeqs
        assert_raise( RuntimeError ) { @matrix.type = :foo }
        assert_equal :DnaSeqs, @matrix.type
      end

      def test_nexml; end

      def test_otus
        otus = Bio::NeXML::Otus.new( 'otus' )
        @matrix.otus = otus
        assert_equal otus, @matrix.otus
        assert_equal [ @matrix ], otus.characters
      end

      def test_add_states
        ss = Bio::NeXML::States.new( 'ss' )
        @format.add_states( ss )
        assert @format.has_states?( ss )
        assert_equal @format, ss.format
      end

      def test_add_char
        ch = Bio::NeXML::Char.new( 'ch' )
        @format.add_char( ch )
        assert @format.has_char?( ch )
        assert_equal @format, ch.format
      end

      def test_add_sequence
        seq = Bio::NeXML::Sequence.new
        @row.add_sequence( seq )
        assert @row.has_sequence?( seq )
        assert_equal @row, seq.row
      end

      def test_delete_states
        assert_equal @states, @format.delete_states( @states )
        assert !@format.has_states?( @states )
        assert_nil @states.format
      end

      def test_delete_char
        assert_equal @char1, @format.delete_char( @char1 )
        assert !@format.has_char?( @char1 )
        assert_nil @char1.format
      end

      def test_delete_sequence
        assert_equal @sequence, @row.delete_sequence( @sequence )
        assert !@row.has_sequence?( @sequence )
        assert_nil @sequence.row
      end

      def test_states
        assert_equal [ @states ], @format.states
        ss = Bio::NeXML::States.new( 'ss' )
        @format.states = [ ss ]
        assert_equal [ ss ], @format.states
      end

      def test_chars
        assert_equal [ @char1, @char2 ], @format.chars
        ch = Bio::NeXML::Char.new( 'ch' )
        @format.chars = [ ch ]
        assert_equal [ ch ], @format.chars
      end

      def test_sequences
        assert_equal [ @sequence ], @row.sequences
        seq = Bio::NeXML::Sequence.new
        @row.sequences = [ seq ]
        assert_equal [ seq ], @row.sequences
      end

      def test_get_states_by_id
        assert_equal @states, @format.get_states_by_id( 'states' )
      end

      def test_get_char_by_id
        assert_equal @char1, @format.get_char_by_id( 'char1' )
      end

      def test_each_states
        c = 0
        @format.each_states do |s|
          assert @format.has_states?( s )
          c += 1
        end
        assert_equal 1, c
      end
      
      def test_each_char
        c = 0
        @format.each_char do |ch|
          assert @format.has_char?( ch )
          c += 1
        end
        assert_equal 2, c
      end

      def test_each_sequence
        c = 0
        @row.each_sequence do |s|
          assert @row.has_sequence?( s )
          c += 1
        end
        assert_equal 1, c
      end

      def test_number_of_states
        assert_equal 1, @format.number_of_states
      end

      def test_number_of_chars
        assert_equal 2, @format.number_of_chars
      end

      def test_number_of_sequences
        assert_equal 1, @row.number_of_sequences
      end
    end
  end #end module NeXML
end #end module Bio
