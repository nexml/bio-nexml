require 'bio/db/nexml/writer'

module Bio
  module NeXML

    module TestWriterHelper
      # This module defines test helpers.
      # TEST_FILE_PATH points to a very small nexml file that defines all the nexml elements.
      # The idea is to initialize two XML::Node objects: first, by parsing the test file, and
      # the second by calling serialize_* methods on NeXML::Writer object and assert their equality.
      # If they are equal, the NeXML::Writer#serialize_* methods pass the test. This equality is
      # asserted by the match? helper method defined in this module.

      TEST_FILE_PATH = File.join File.dirname(__FILE__), ['..'] * 4, 'data', 'nexml', 'test.xml'

      # Parse the test file.
      def parse
        @doc = XML::Document.file TEST_FILE_PATH, :options => XML::Parser::Options::NOBLANKS
      end

      # Return the first occurence of a tag by name in the test file.
      def element( name )
        @doc.find( "//nex:#{name}", 'nex:http://www.nexml.org/2009' )
      end

      # If an attribte is associated with a namespace, say: 'xsi:type', the XML::Attr#name function
      # returns the name without the namespace prefix. The redefined XML::Attr#name returns the 
      # qualified name( with the prefix ) of the node.
      XML::Attr.class_eval do
        alias old_name name
        def name
          return old_name unless self.ns?
          "#{self.ns.prefix}:#{old_name}"
        end
      end

      # Compare two XML::Nodes for equality based on the following criteria:
      # * same name,
      # * same attributes( irrespective of the order )
      # * same children( irrespective of the order )
      def match?( node1, node2 )
        # not equal if their names do not match

        attributes1 = node1.attributes.map( &:to_s )
        attributes2 = node2.attributes.map( &:to_s )

        # not equal if both do not have the same number of attributes
        return false unless attributes1.length == attributes2.length

        # if the nodes have same number of attributes, compare them
        unless attributes1.empty? and attributes2.empty?
          attributes1.each do |attr1|
            # not equal if attr1 can not be found in attributes2
            return false unless attributes2.find{ |attr2| attr1 == attr2 }
          end 
        end

        children1 = node1.children
        children2 = node2.children

        # not equal if number of child nodes do not match
        return false unless children1.length == children2.length

        # if the nodes have same number of children, compare them
        unless children1.empty? and children2.empty?
          children1.each do |child1|
            #not equal if child1 can't be found in children2
            return false unless children2.find{ |child2| match?( child1, child2 ) }
          end
        end

        true
      end

    end

    class TestTestWriterHelper < Test::Unit::TestCase
      include TestWriterHelper

      # should pass the criteria( see the definition of match? ) of a node's equality.
      def test_match
        # two nodes with same name
        node1 = XML::Node.new( 'nexml' )
        node2 = XML::Node.new( 'nexml' )

        # same attributes
        node1.attributes = { :version => '0.9', :generator => 'bioruby' }
        node2.attributes = { :generator => 'bioruby', :version => '0.9' }

        # childe nodes for node1
        child11 = XML::Node.new( 'otus' )
        child12 = XML::Node.new( 'otus' )
        child11.attributes = { :id => 'taxa1', :label => 'Taxa 1' }
        child12.attributes = { :id => 'taxa2', :label => 'Taxa 2' }

        # childe nodes for node2
        child21 = XML::Node.new( 'otus' )
        child22 = XML::Node.new( 'otus' )
        child21.attributes = { :id => 'taxa1', :label => 'Taxa 1' }
        child22.attributes = { :id => 'taxa2', :label => 'Taxa 2' }

        # same children
        node1 << child11
        node1 << child12
        node2 << child22
        node2 << child21

        assert match?( node1, node2 )
      end
    end

    class TestWriter < Test::Unit::TestCase
      include TestWriterHelper

      def setup
        @writer = Bio::NeXML::Writer.new; parse
      end

      # should respond properly to :id, and :label
      def test_attributes_1
        otu1 = Bio::NeXML::Otu.new( 'o1', :label => 'otu 1' )
        otu2 = Bio::NeXML::Otu.new( 'o2' )

        ae1 = { :id => 'o1', :label => 'otu 1' }
        ae2 = { :id => 'o2' }

        aa1 = @writer.send( :attributes, otu1, :id, :label )
        aa2 = @writer.send( :attributes, otu2, :id, :label )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # should respond properly to :symbol
      def test_attributes_2
        ds = Bio::NeXML::State.new( 'ds1', 'A' )
        ss = Bio::NeXML::State.new( 'ss1', '1' )

        ae1 = { :symbol => 'A' }
        ae2 = { :symbol => '1' }

        aa1 = @writer.send( :attributes, ds, :symbol )
        aa2 = @writer.send( :attributes, ss, :symbol )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # should respond properly to :"xsi:type"
      def test_attributes_3
        t = Bio::NeXML::IntTree.new 'tree1'
        n = Bio::NeXML::FloatNetwork.new 'network1'
        dc1 = Bio::NeXML::DnaSeqs.new( 'dnacharacters1' )
        dc2 = Bio::NeXML::DnaCells.new( 'dnacharacters2' )

        ae1 = { :"xsi:type" => "nex:IntTree" }
        ae2 = { :"xsi:type" => "nex:FloatNetwork" }
        ae3 = { :"xsi:type" => "nex:DnaSeqs" }
        ae4 = { :"xsi:type" => "nex:DnaCells" }

        aa1 = @writer.send( :attributes, t, :"xsi:type" )
        aa2 = @writer.send( :attributes, n, :"xsi:type" )
        aa3 = @writer.send( :attributes, dc1, :"xsi:type" )
        aa4 = @writer.send( :attributes, dc2, :"xsi:type" )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
        assert_equal ae3, aa3
        assert_equal ae4, aa4
      end

      # should respond properly to :root and :otu
      def test_attributes_4
        o = Bio::NeXML::Otu.new( 'o1' )
        n1 = Bio::NeXML::Node.new( 'n1', :otu => o, :root => true )
        n2 = Bio::NeXML::Node.new( 'n2' )

        ae1 = { :otu => 'o1', :root => 'true' }
        ae2 = {}

        aa1 = @writer.send( :attributes, n1, :otu, :root )
        aa2 = @writer.send( :attributes, n2, :otu, :root )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # should respond properly to :otus
      def test_attributes_5
        o = Bio::NeXML::Otus.new( 'o1' )
        t = Bio::NeXML::Trees.new( 't1', :otus => o )

        ae = { :otus => 'o1' }
        aa = @writer.send( :attributes, t, :otus )

        assert_equal ae, aa
      end

      # shold respond properly to :char and :state
      def test_attributes_6
        cc = Bio::NeXML::ContinuousCell.new
        cc.char = Bio::NeXML::Char.new( 'cc1' )
        cc.state = '-0.9'
        dc = Bio::NeXML::Cell.new
        dc.char = Bio::NeXML::Char.new( 'dc1', nil )
        dc.state = Bio::NeXML::State.new 'ds1', 'A'

        ae1 = { :char => 'cc1', :state => '-0.9' }
        ae2 = { :char => 'dc1', :state => 'ds1' }

        aa1 = @writer.send( :attributes, cc, :char, :state )
        aa2 = @writer.send( :attributes, dc, :char, :state )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # shold respond properly to :source and :target and :length
      def test_attributes_7
        n1 = Bio::NeXML::Node.new 'n1'
        n2 = Bio::NeXML::Node.new 'n2'
        e = Bio::NeXML::IntEdge.new 'e1', :source => n1, :target => n2
        re = Bio::NeXML::RootEdge.new 're1', :target => n1, :length => 2

        ae1 = { :source => 'n1', :target => 'n2', :length => '0' }
        ae2 = { :target => 'n1', :length => '2' }

        aa1 = @writer.send( :attributes, e, :source, :target, :length )
        aa2 = @writer.send( :attributes, re, :source, :target, :length )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # shold respond properly to :states
      def test_attributes_8
        ds = Bio::NeXML::States.new( 'ds1' )
        dc = Bio::NeXML::Char.new( 'dc1', :states => ds )

        ae = { :states => 'ds1' }

        aa = @writer.send( :attributes, dc, :states )

        assert_equal ae, aa
      end

      # tag should create a XML::Node
      def test_create_node
        node1 = XML::Node.new( 'nexml' )
        node1.attributes = { :version => '0.9' }

        node2 = @writer.send( :create_node, 'nexml', :version => '0.9' )

        assert_equal node1, node2
      end

      def test_serialize_otu
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        output = @writer.serialize_otu( o1 )
        parsed = element( 'otu' ).first

        assert match?( parsed, output )
      end

      def test_serialize_otus
        taxa1 = Bio::NeXML::Otus.new 'taxa1', :label => 'A taxa block'
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        o2 = Bio::NeXML::Otu.new 'o2', :label => 'A taxon'
        taxa1.add_otu( o1 )
        taxa1.add_otu( o2 )

        output = @writer.serialize_otus( taxa1 )
        parsed = element( 'otus' ).first

        assert match?( parsed, output )
      end

      def test_serialize_node
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', :otu => o1, :root => true, :label => 'A node'

        output = @writer.serialize_node( n1 )
        parsed = element( 'node' ).first

        assert match?( parsed, output )
      end

      def test_serialize_edge
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        o2 = Bio::NeXML::Otu.new 'o2', :label => 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', :otu => o1, :root => true, :label => 'A node'
        n2 = Bio::NeXML::Node.new 'n2', :otu => o2, :root => false, :label => 'A node'
        e1 = Bio::NeXML::Edge.new 'e1', :source => n1, :target => n2, :length => 0.4353, :label => 'An edge'

        output = @writer.serialize_edge( e1 )
        parsed = element( 'edge' ).first

        assert match?( parsed, output )
      end

      def test_serailize_rootedge
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', :otu => o1, :root => true, :label => 'A node'
        re1 = Bio::NeXML::RootEdge.new 're1', :target => n1, :length => 0.5, :label => 'A rootedge'

        output = @writer.serialize_rootedge( re1 )
        parsed = element( 'rootedge' ).first

        assert match?( parsed, output )
      end

      def test_serialize_tree
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', :otu => o1, :root => true, :label => 'A node'
        n2 = Bio::NeXML::Node.new 'n2', :otu => nil, :root => false, :label => 'A node'
        re1 = Bio::NeXML::RootEdge.new 're1', :target => n1, :length => 0.5, :label => 'A rootedge'
        e1 = Bio::NeXML::Edge.new 'e1', :source => n1, :target => n2, :length => 0.4353, :label => 'An edge'
        tree1 = Bio::NeXML::FloatTree.new 'tree1', :label => 'A float tree'
        tree1.add_node n1
        tree1.add_node n2
        tree1.add_rootedge re1
        tree1.add_edge e1

        output = @writer.serialize_tree( tree1 )
        parsed = element( 'tree' ).first
        assert match?( parsed, output )
      end

      def test_serialize_network
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1n1', :otu => o1, :root => true, :label => 'A node'
        n2 = Bio::NeXML::Node.new 'n1n2', :otu => nil, :root => false, :label => 'A node'
        e1 = Bio::NeXML::Edge.new 'n1e1', :source => n1, :target => n2, :length => 1, :label => 'An edge'
        e2 = Bio::NeXML::Edge.new 'n1e2', :source => n2, :target => n2, :length => 0, :label => 'An edge'
        network1 = Bio::NeXML::IntNetwork.new 'network1', :label => 'An int network'
        network1.add_node n1
        network1.add_node n2
        network1.add_edge e1
        network1.add_edge e2

        output = @writer.serialize_network( network1 )
        parsed = element( 'network' ).first

        assert match?( parsed, output )
      end

      def test_serialize_trees
        o1 = Bio::NeXML::Otu.new 'o1', :label => 'A taxon'

        n1 = Bio::NeXML::Node.new 'n1', :otu => o1, :root => true, :label => 'A node'
        n2 = Bio::NeXML::Node.new 'n2', :otu => nil, :root => false, :label => 'A node'
        re1 = Bio::NeXML::RootEdge.new 're1', :target => n1, :length => 0.5, :label => 'A rootedge'
        e1 = Bio::NeXML::Edge.new 'e1', :source => n1, :target => n2, :length => 0.4353, :label => 'An edge'
        tree1 = Bio::NeXML::FloatTree.new 'tree1', :label => 'A float tree'

        tree1.add_node n1
        tree1.add_node n2
        tree1.add_rootedge re1
        tree1.add_edge e1

        n1 = Bio::NeXML::Node.new 'n1n1', :otu => o1, :root => true, :label => 'A node'
        n2 = Bio::NeXML::Node.new 'n1n2', :otu => nil, :root => false, :label => 'A node'
        e1 = Bio::NeXML::Edge.new 'n1e1', :source => n1, :target => n2, :length => 1, :label => 'An edge'
        e2 = Bio::NeXML::Edge.new 'n1e2', :source => n2, :target => n2, :length => 0, :label => 'An edge'
        network1 = Bio::NeXML::IntNetwork.new 'network1', :label => 'An int network'

        network1.add_node n1
        network1.add_node n2
        network1.add_edge e1
        network1.add_edge e2

        taxa1 = Bio::NeXML::Otus.new 'taxa1'
        trees1 = Bio::NeXML::Trees.new 'trees1', :otus => taxa1, :label => 'A tree container'
        trees1 << tree1
        trees1 << network1

        output = @writer.serialize_trees( trees1 )
        parsed = element( 'trees' ).first
        assert match?( parsed, output )
      end

      def test_serialize_member
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'

        output = @writer.serialize_member( ss1 )
        parsed = element( 'member' ).first

        assert match?( parsed, output )
      end

      def test_serialize_uncertain_state_set
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'
        ss2 = Bio::NeXML::State.new 'ss2', :symbol => '2'
        uss1 = Bio::NeXML::State.new 'ss5', :symbol => '5'
        uss1.uncertain( true )
        uss1.add_member( ss1 )
        uss1.add_member( ss2 )

        output = @writer.serialize_uncertain_state_set( uss1 )
        parsed = element( 'uncertain_state_set' ).first

        assert match?( parsed, output )
      end

      def test_serialize_polymorphic_state_set
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'
        ss2 = Bio::NeXML::State.new 'ss2', :symbol => '2'
        pss1 = Bio::NeXML::State.new 'ss4', :symbol => '4'
        pss1.polymorphic( true )
        pss1.add_member( ss1 )
        pss1.add_member( ss2 )

        output = @writer.serialize_polymorphic_state_set( pss1 )
        parsed = element( 'polymorphic_state_set' ).first

        assert match?( parsed, output )
      end

      def test_serialize_state
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'

        output = @writer.serialize_state( ss1 )
        parsed = element( 'state' ).first

        assert match?( parsed, output )
      end

      def test_serialize_states
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'
        ss2 = Bio::NeXML::State.new 'ss2', :symbol => '2'
        sss1 = Bio::NeXML::States.new 'sss1'

        pss1 = Bio::NeXML::State.new 'ss4', :symbol => '4'
        pss1.polymorphic( true )
        pss1.add_member( ss1 )
        pss1.add_member( ss2 )

        uss1 = Bio::NeXML::State.new 'ss5', :symbol => '5'
        uss1.uncertain( true )
        uss1.add_member( ss1 )
        uss1.add_member( ss2 )

        sss1.add_state( ss1 )
        sss1.add_state( ss2 )
        
        sss1.add_state( uss1 )
        sss1.add_state( pss1 )

        output = @writer.serialize_states( sss1 )
        parsed = element( 'states' ).first

        assert match?( parsed, output )
      end

      def test_char
        sss1 = Bio::NeXML::States.new 'sss1'
        sc1 = Bio::NeXML::Char.new 'sc1', :states => sss1

        output = @writer.serialize_char( sc1 )
        parsed = element( 'char' ).first

        assert match?( parsed, output )
      end

      def test_format
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'
        ss2 = Bio::NeXML::State.new 'ss2', :symbol => '2'
        sss1 = Bio::NeXML::States.new 'sss1'

        pss1 = Bio::NeXML::State.new 'ss4', :symbol => '4'
        pss1.polymorphic( true )
        pss1.add_member( ss1 )
        pss1.add_member( ss2 )

        uss1 = Bio::NeXML::State.new 'ss5', :symbol => '5'
        uss1.uncertain( true )
        uss1.add_member( ss1 )
        uss1.add_member( ss2 )

        sss1.add_state( ss1 )
        sss1.add_state( ss2 )
        sss1.add_state( uss1 )
        sss1.add_state( pss1 )

        sc1 = Bio::NeXML::Char.new 'sc1', :states => sss1
        sc2 = Bio::NeXML::Char.new 'sc2', :states => sss1

        sf1 = Bio::NeXML::Format.new
        sf1.add_states( sss1 )
        sf1.add_char( sc1 )
        sf1.add_char( sc2 )

        output = @writer.serialize_format( sf1 )
        parsed = element( 'format' ).first

        assert match?( parsed, output )
      end

      def test_serialize_seq
        sseq1 = Bio::NeXML::Sequence.new
        sseq1.value = "1 2"

        output = @writer.serialize_seq( sseq1 )
        parsed = element( 'seq' ).first

        assert match?( parsed, output )
      end

      def test_serialize_cell
        sss2 = Bio::NeXML::States.new 'sss2'
        ss6 = Bio::NeXML::State.new 'ss6', :symbol => '1'
        sc3 = Bio::NeXML::Char.new 'sc3', :states => sss2

        scell1 = Bio::NeXML::Cell.new
        scell1.char = sc3
        scell1.state = ss6

        output = @writer.serialize_cell( scell1 )
        parsed = element( 'cell' ).first

        assert match?( parsed, output )
      end

      def test_sereialize_seq_row
        o1 = Bio::NeXML::Otu.new 'o1'
        sseq1 = Bio::NeXML::Sequence.new
        sseq1.value = "1 2"
        sr1 = Bio::NeXML::SeqRow.new 'sr1', :otu => o1
        sr1.add_sequence( sseq1 )

        output = @writer.serialize_seq_row( sr1 )
        parsed = element( 'row' ).first

        assert match?( parsed, output )
      end

      def test_serialize_cell_row
        o1 = Bio::NeXML::Otu.new 'o1'
        sss2 = Bio::NeXML::States.new 'sss2'
        ss6 = Bio::NeXML::State.new 'ss6', :symbol => '1'
        sc3 = Bio::NeXML::Char.new 'sc3', :states => sss2

        scell1 = Bio::NeXML::Cell.new
        scell1.char = sc3
        scell1.state = ss6

        sr3 = Bio::NeXML::CellRow.new 'sr3', :otu => o1
        sr3.add_cell( scell1 )

        output = @writer.serialize_cell_row( sr3 )
        parsed = element( 'row' ).last

        assert match?( parsed, output )
      end

      def test_serialize_matrix
        o1 = Bio::NeXML::Otu.new 'o1'
        o2 = Bio::NeXML::Otu.new 'o2'

        sseq1 = Bio::NeXML::Sequence.new
        sseq1.value = "1 2"

        sseq2 = Bio::NeXML::Sequence.new
        sseq2.value = "2 2"

        sr1 = Bio::NeXML::SeqRow.new 'sr1', :otu => o1
        sr2 = Bio::NeXML::SeqRow.new 'sr2', :otu => o2

        sr1.add_sequence( sseq1 )
        sr2.add_sequence( sseq2 )

        m = Bio::NeXML::Matrix.new
        m.add_row( sr1 )
        m.add_row( sr2 )

        output = @writer.serialize_matrix( m )
        parsed = element( 'matrix' ).first

        assert match?( parsed, output )
      end

      def test_serialize_characters
        ss1 = Bio::NeXML::State.new 'ss1', :symbol => '1'
        ss2 = Bio::NeXML::State.new 'ss2', :symbol => '2'
        sss1 = Bio::NeXML::States.new 'sss1'

        pss1 = Bio::NeXML::State.new 'ss4', :symbol => '4'
        pss1.polymorphic( true )
        pss1.add_member( ss1 )
        pss1.add_member( ss2 )

        uss1 = Bio::NeXML::State.new 'ss5', :symbol => '5'
        uss1.uncertain( true )
        uss1.add_member( ss1 )
        uss1.add_member( ss2 )

        sss1.add_state( ss1 )
        sss1.add_state( ss2 )
        sss1.add_state( uss1 )
        sss1.add_state( pss1 )

        sc1 = Bio::NeXML::Char.new 'sc1', :states => sss1
        sc2 = Bio::NeXML::Char.new 'sc2', :states => sss1

        sf1 = Bio::NeXML::Format.new
        sf1.add_states( sss1 )
        sf1.add_char( sc1 )
        sf1.add_char( sc2 )

        o1 = Bio::NeXML::Otu.new 'o1'
        o2 = Bio::NeXML::Otu.new 'o2'

        sseq1 = Bio::NeXML::Sequence.new
        sseq1.value = "1 2"

        sseq2 = Bio::NeXML::Sequence.new
        sseq2.value = "2 2"

        sr1 = Bio::NeXML::SeqRow.new 'sr1', :otu => o1
        sr2 = Bio::NeXML::SeqRow.new 'sr2', :otu => o2

        sr1.add_sequence( sseq1 )
        sr2.add_sequence( sseq2 )

        m = Bio::NeXML::Matrix.new
        m.add_row( sr1 )
        m.add_row( sr2 )

        taxa1 = Bio::NeXML::Otus.new 'taxa1'

        c1 = Bio::NeXML::Characters.new 'standardchars6', :otus => taxa1, :label => 'Standard sequences'
        c1.format = sf1
        c1.matrix = m

        output = @writer.serialize_characters( c1 )
        parsed = element( 'characters' ).first

        assert match?( parsed, output )
      end

    end # end class TestWriter

  end # end module NeXML
end # end module Bio
