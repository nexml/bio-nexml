module Bio
  module NeXML

    module TestWriterData
      TEST_FILE_PATH = File.join File.dirname(__FILE__), ['..'] * 4, 'data', 'nexml', 'test.xml'

      def parse
        @doc = XML::Document.file TEST_FILE_PATH, :options => XML::Parser::Options::NOBLANKS
      end

      def element( name )
        @doc.find_first( "//nex:#{name}", 'nex:http://www.nexml.org/1.0' )
      end
      alias method_missing element

    end

    class TestWriter < Test::Unit::TestCase
      include TestWriterData

      def setup
        @writer = Bio::NeXML::Writer.new
        parse
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

        assert_equal tree[ 'id' ], nexml[ 'id' ]
        assert_equal tree[ 'label' ], nexml[ 'label' ]
        #practically this is correct. theoritically i should have
        #attached xsi:type to the xsi namespace.
        assert_equal tree[ 'type' ], nexml[ 'xsi:type' ]

        en1 = tree.children.find{ |n| n[ 'id' ] == 'n1' }
        en2 = tree.children.find{ |n| n[ 'id' ] == 'n2' }
        an1 = nexml.children.find{ |n| n[ 'id' ] == 'n1' }
        an2 = nexml.children.find{ |n| n[ 'id' ] == 'n2' }

        assert_equal en1[ 'id' ], an1[ 'id' ]
        assert_equal en1[ 'otu' ], an1[ 'otu' ]
        assert_equal en1[ 'root' ], an1[ 'root' ]
        assert_equal en1[ 'label' ], an1[ 'label' ]
        assert_equal en2[ 'id' ], an2[ 'id' ]
        assert_equal en2[ 'otu' ], an2[ 'otu' ]
        assert_equal en2[ 'root' ], an2[ 'root' ]
        assert_equal en2[ 'label' ], an2[ 'label' ]

        ere1 = tree.children.find{ |n| n[ 'id' ] == 're1' }
        are1 = nexml.children.find{ |n| n[ 'id' ] == 're1' }

        assert_equal ere1[ 'id' ], are1[ 'id' ]
        assert_equal ere1[ 'target' ], are1[ 'target' ]
        assert_equal ere1[ 'length' ], are1[ 'length' ]
        assert_equal ere1[ 'label' ], are1[ 'label' ]

        ee1 = tree.children.find{ |n| n[ 'id' ] == 'e1' }
        ae1 = nexml.children.find{ |n| n[ 'id' ] == 'e1' }

        assert_equal ee1[ 'id' ], ae1[ 'id' ]
        assert_equal ee1[ 'source' ], ae1[ 'source' ]
        assert_equal ee1[ 'target' ], ae1[ 'target' ]
        assert_equal ee1[ 'length' ], ae1[ 'length' ]
        assert_equal ee1[ 'label' ], ae1[ 'label' ]
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


        assert_equal network[ 'id' ], nexml[ 'id' ]
        assert_equal network[ 'label' ], nexml[ 'label' ]
        assert_equal network[ 'type' ], nexml[ 'xsi:type' ]

        en1 = network.children.find{ |n| n[ 'id' ] == 'n1n1' }
        en2 = network.children.find{ |n| n[ 'id' ] == 'n1n2' }
        an1 = nexml.children.find{ |n| n[ 'id' ] == 'n1n1' }
        an2 = nexml.children.find{ |n| n[ 'id' ] == 'n1n2' }

        assert_equal en1[ 'id' ], an1[ 'id' ]
        assert_equal en1[ 'otu' ], an1[ 'otu' ]
        assert_equal en1[ 'root' ], an1[ 'root' ]
        assert_equal en1[ 'label' ], an1[ 'label' ]
        assert_equal en2[ 'id' ], an2[ 'id' ]
        assert_equal en2[ 'otu' ], an2[ 'otu' ]
        assert_equal en2[ 'root' ], an2[ 'root' ]
        assert_equal en2[ 'label' ], an2[ 'label' ]

        ee1 = network.children.find{ |n| n[ 'id' ] == 'n1e1' }
        ee2 = network.children.find{ |n| n[ 'id' ] == 'n1e2' }
        ae1 = nexml.children.find{ |n| n[ 'id' ] == 'n1e1' }
        ae2 = nexml.children.find{ |n| n[ 'id' ] == 'n1e2' }

        assert_equal ee1[ 'id' ], ae1[ 'id' ]
        assert_equal ee1[ 'source' ], ae1[ 'source' ]
        assert_equal ee1[ 'target' ], ae1[ 'target' ]
        assert_equal ee1[ 'length' ], ae1[ 'length' ]
        assert_equal ee1[ 'label' ], ae1[ 'label' ]
        assert_equal ee2[ 'id' ], ae2[ 'id' ]
        assert_equal ee2[ 'source' ], ae2[ 'source' ]
        assert_equal ee2[ 'target' ], ae2[ 'target' ]
        assert_equal ee2[ 'length' ], ae2[ 'length' ]
        assert_equal ee2[ 'label' ], ae2[ 'label' ]
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

        assert_equal uncertain_state_set[ 'id' ], nexml[ 'id' ]
        assert_equal uncertain_state_set[ 'label' ], nexml[ 'label' ]

        es1 = uncertain_state_set.children.find{ |n| n[ 'state' ] == 'ss1' }
        es2 = uncertain_state_set.children.find{ |n| n[ 'state' ] == 'ss2' }
        as1 = nexml.children.find{ |n| n[ 'state' ] == 'ss1' }
        as2 = nexml.children.find{ |n| n[ 'state' ] == 'ss2' }

        assert_equal es1, as1
        assert_equal es2, as2
      end

      def test_serialize_polymorphic_state_set
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        ss2 = Bio::NeXML::StandardState.new 'ss2', '2'
        pss1 = Bio::NeXML::StandardState.new 'ss4', '4'
        pss1.polymorphic = true
        pss1 << [ss1, ss2]
        nexml = @writer.serialize_polymorphic_state_set( pss1 )

        assert_equal polymorphic_state_set[ 'id' ], nexml[ 'id' ]
        assert_equal polymorphic_state_set[ 'label' ], nexml[ 'label' ]

        es1 = polymorphic_state_set.children.find{ |n| n[ 'state' ] == 'ss1' }
        es2 = polymorphic_state_set.children.find{ |n| n[ 'state' ] == 'ss2' }
        as1 = nexml.children.find{ |n| n[ 'state' ] == 'ss1' }
        as2 = nexml.children.find{ |n| n[ 'state' ] == 'ss2' }

        assert_equal es1, as1
        assert_equal es2, as2
      end

      def test_state
        ss1 = Bio::NeXML::StandardState.new 'ss1', '1'
        nexml = @writer.serialize_state( ss1 )

        assert_equal state[ 'id' ], nexml[ 'id' ]
        assert_equal state[ 'label' ], nexml[ 'label' ]
        assert_equal state[ 'symbol' ], nexml[ 'symbol' ]
      end

    end # end class TestWriter

  end # end module NeXML
end # end module Bio
