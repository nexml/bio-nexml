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
        @doc.find_first( "//nex:#{name}", 'nex:http://www.nexml.org/1.0' )
      end
      alias method_missing element

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
        return false unless node1.name == node2.name

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
        otu1 = Bio::NeXML::Otu.new 'o1', 'otu 1'
        otu2 = Bio::NeXML::Otu.new 'o2'

        ae1 = { :id => 'o1', :label => 'otu 1' }
        ae2 = { :id => 'o2' }

        aa1 = @writer.send( :attributes, otu1, :id, :label )
        aa2 = @writer.send( :attributes, otu2, :id, :label )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # should respond properly to :symbol
      def test_attributes_2
        ds = Bio::NeXML::DnaState.new 'ds1', 'A'
        ss = Bio::NeXML::StandardState.new 'ss1', '1'

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
        dc1 = Bio::NeXML::DnaSeqs.new 'dnacharacters1', nil
        dc2 = Bio::NeXML::DnaCells.new 'dnacharacters2', nil

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
        o = Bio::NeXML::Otu.new 'o1'
        n1 = Bio::NeXML::Node.new 'n1', o, true
        n2 = Bio::NeXML::Node.new 'n2'

        ae1 = { :otu => 'o1', :root => 'true' }
        ae2 = {}

        aa1 = @writer.send( :attributes, n1, :otu, :root )
        aa2 = @writer.send( :attributes, n2, :otu, :root )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # should respond properly to :otus
      def test_attributes_5
        o = Bio::NeXML::Otus.new 'o1'
        t = Bio::NeXML::Trees.new 't1', o

        ae = { :otus => 'o1' }
        aa = @writer.send( :attributes, t, :otus )

        assert_equal ae, aa
      end

      # shold respond properly to :char and :state
      def test_attributes_6
        cc = Bio::NeXML::ContinuousCell.new
        cc.char = Bio::NeXML::ContinuousChar.new( 'cc1' )
        cc.state = '-0.9'
        dc = Bio::NeXML::DnaCell.new
        dc.char = Bio::NeXML::DnaChar.new( 'dc1', nil )
        dc.state = Bio::NeXML::DnaState.new 'ds1', 'A'

        ae1 = { :char => 'cc1', :state => '-0.9' }
        ae2 = { :char => 'dc1', :state => 'ds1' }

        aa1 = @writer.send( :attributes, cc, :char, :state )
        aa2 = @writer.send( :attributes, dc, :char, :state )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # shold respond properly to :source and :target and :length
      def test_attributes_7
        n1 = Bio::NeXML::Node.new 'n1', nil
        n2 = Bio::NeXML::Node.new 'n2', nil
        e = Bio::NeXML::IntEdge.new 'e1', n1, n2
        re = Bio::NeXML::RootEdge.new 're1', n1, 2

        ae1 = { :source => 'n1', :target => 'n2' }
        ae2 = { :target => 'n1', :length => '2' }

        aa1 = @writer.send( :attributes, e, :source, :target, :length )
        aa2 = @writer.send( :attributes, re, :source, :target, :length )

        assert_equal ae1, aa1
        assert_equal ae2, aa2
      end

      # shold respond properly to :states
      def test_attributes_8
        ds = Bio::NeXML::DnaStates.new 'ds1'
        dc = Bio::NeXML::DnaChar.new( 'dc1', ds )

        ae = { :states => 'ds1' }

        aa = @writer.send( :attributes, dc, :states )

        assert_equal ae, aa
      end

      # tag should create a XML::Node
      # method missing should call tag
      def test_tag
        node1 = XML::Node.new( 'nexml' )
        node1.attributes = { :version => '0.9' }

        node2 = @writer.send( :tag, 'nexml', :version => '0.9' )
        node3 = @writer.send( :nexml, :version => '0.9' )

        assert_equal node1, node2
      end

      def test_serialize_otu
        o1 = Bio::NeXML::Otu.new 'o1', 'A taxon'
        nexml = @writer.serialize_otu( o1 )

        assert_equal otu[ 'id' ], nexml[ 'id' ]
        assert_equal otu[ 'label' ], nexml[ 'label' ]
      end

      def test_serialize_otus
        taxa1 = Bio::NeXML::Otus.new 'taxa1', 'A taxa block'
        o1 = Bio::NeXML::Otu.new 'o1', 'A taxon'
        taxa1 << o1
        nexml = @writer.serialize_otus( taxa1 )

        assert_equal otus[ 'id' ], nexml[ 'id' ]
        assert_equal otus[ 'label' ], nexml[ 'label' ]

        assert_equal otus.child[ 'id' ], nexml.child[ 'id' ]
        assert_equal otus.child[ 'label' ], nexml.child[ 'label' ]
      end

      def test_serialize_node
        o1 = Bio::NeXML::Otu.new 'o1', 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', o1, true, 'A node'
        nexml = @writer.serialize_node( n1 )

        assert_equal node[ 'id' ], nexml[ 'id' ]
        assert_equal node[ 'otu' ], nexml[ 'otu' ]
        assert_equal node[ 'root' ], nexml[ 'root' ]
        assert_equal node[ 'label' ], nexml[ 'label' ]
      end

      def test_serialize_edge
        n1 = Bio::NeXML::Node.new 'n1', o1, true, 'A node'
        n2 = Bio::NeXML::Node.new 'n2', o2, false, 'A node'
        e1 = Bio::NeXML::Edge.new 'e1', n1, n2, 0.4353, 'An edge'
        nexml = @writer.serialize_edge( e1 )

        assert_equal edge[ 'id' ], nexml[ 'id' ]
        assert_equal edge[ 'source' ], nexml[ 'source' ]
        assert_equal edge[ 'target' ], nexml[ 'target' ]
        assert_equal edge[ 'length' ], nexml[ 'length' ]
        assert_equal edge[ 'label' ], nexml[ 'label' ]
      end

      def test_serailize_rootedge
        n1 = Bio::NeXML::Node.new 'n1', o1, true, 'A node'
        re1 = Bio::NeXML::RootEdge.new 're1', n1, 0.5, 'A rootedge'
        nexml = @writer.serialize_edge( re1 )

        assert_equal rootedge[ 'id' ], nexml[ 'id' ]
        assert_equal rootedge[ 'target' ], nexml[ 'target' ]
        assert_equal rootedge[ 'length' ], nexml[ 'length' ]
        assert_equal rootedge[ 'label' ], nexml[ 'label' ]
      end

      def test_serialize_tree
        o1 = Bio::NeXML::Otu.new 'o1', 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1', o1, true, 'A node'
        n2 = Bio::NeXML::Node.new 'n2', nil, false, 'A node'
        re1 = Bio::NeXML::RootEdge.new 're1', n1, 0.5, 'A rootedge'
        e1 = Bio::NeXML::Edge.new 'e1', n1, n2, 0.4353, 'An edge'
        tree1 = Bio::NeXML::FloatTree.new 'tree1', 'A float tree'
        tree1.add_node n1
        tree1.add_node n2
        tree1.add_rootedge re1
        tree1.add_edge e1
        nexml = @writer.serialize_tree( tree1 )

        assert match?( tree, nexml )
      end

      def test_serialize_network
        o1 = Bio::NeXML::Otu.new 'o1', 'A taxon'
        n1 = Bio::NeXML::Node.new 'n1n1', o1, true, 'A node'
        n2 = Bio::NeXML::Node.new 'n1n2', nil, false, 'A node'
        e1 = Bio::NeXML::Edge.new 'n1e1', n1, n2, 1, 'An edge'
        e2 = Bio::NeXML::Edge.new 'n1e2', n2, n2, 0, 'An edge'
        network1 = Bio::NeXML::IntNetwork.new 'network1', 'An int network'
        network1.add_node n1
        network1.add_node n2
        network1.add_edge e1
        network1.add_edge e2
        nexml = @writer.serialize_network( network1 )

        assert match?( network, nexml )
      end

      def test_serialize_member
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        nexml = @writer.serialize_member( ss1 )

        assert_equal member[ 'state' ], nexml[ 'state' ]
      end

      def test_serialize_uncertain_state_set
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        ss2 = Bio::NeXML::StandardState.new 'ss2', '2'
        uss1 = Bio::NeXML::StandardState.new 'ss5', '5'
        uss1.uncertain = true
        uss1 << [ss1, ss2]
        nexml = @writer.serialize_uncertain_state_set( uss1 )

        assert match?( uncertain_state_set, nexml )
      end

      def test_serialize_polymorphic_state_set
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        ss2 = Bio::NeXML::StandardState.new 'ss2', '2'
        pss1 = Bio::NeXML::StandardState.new 'ss4', '4'
        pss1.polymorphic = true
        pss1 << [ss1, ss2]
        nexml = @writer.serialize_polymorphic_state_set( pss1 )

        assert match?( polymorphic_state_set, nexml )
      end

      def test_state
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        nexml = @writer.serialize_state( ss1 )

        assert match?( state, nexml )
      end

    end # end class TestWriter

  end # end module NeXML
end # end module Bio
