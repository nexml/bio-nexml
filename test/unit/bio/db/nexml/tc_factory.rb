module Bio
  module NeXML
    class TestFactory < Test::Unit::TestCase
      def setup
        @nexml = Bio::NeXML::Nexml.new
        @otus = @nexml.create_otus
      end

      def test_otus
        assert @otus.kind_of? Bio::NeXML::Otus
      end
      
      def test_otu
        otu = @otus.create_otu
        assert otu.kind_of? Bio::NeXML::Otu
      end
      
      def test_trees
        trees = @nexml.create_trees( :otus => @otus )
        otu = @otus.create_otu
        assert_equal @otus, trees.otus
        assert trees.instance_of? Bio::NeXML::Trees
        
        floattree = trees.create_tree        
        assert floattree.kind_of? Bio::NeXML::Tree
        assert floattree.kind_of? Bio::Tree
        assert floattree.kind_of? Bio::NeXML::FloatTree
        floatnode = floattree.create_node( :otu => otu )
        assert floatnode.kind_of? Bio::NeXML::Node
        assert floatnode.kind_of? Bio::Tree::Node
        assert_equal otu, floatnode.otu        
        
        floatedge = floattree.create_edge( :source => floatnode, :target => floatnode )
        assert floatedge.kind_of? Bio::NeXML::Edge
        assert floatedge.kind_of? Bio::Tree::Edge
        assert floatedge.kind_of? Bio::NeXML::FloatEdge
        floatrootedge = floattree.create_rootedge( :target => floatnode )
        assert floatrootedge.kind_of? Bio::NeXML::Edge
        assert floatrootedge.kind_of? Bio::Tree::Edge
        assert floatrootedge.kind_of? Bio::NeXML::RootEdge
        assert floatrootedge.kind_of? Bio::NeXML::FloatRootEdge
        
        inttree = trees.create_tree( true )
        assert inttree.kind_of? Bio::NeXML::Tree
        assert inttree.kind_of? Bio::Tree
        assert inttree.kind_of? Bio::NeXML::IntTree
        intedge = inttree.create_edge
        assert intedge.kind_of? Bio::NeXML::Edge
        assert intedge.kind_of? Bio::Tree::Edge
        assert intedge.kind_of? Bio::NeXML::IntEdge
        introotedge = inttree.create_rootedge
        assert introotedge.kind_of? Bio::NeXML::Edge
        assert introotedge.kind_of? Bio::Tree::Edge
        assert introotedge.kind_of? Bio::NeXML::RootEdge
        assert introotedge.kind_of? Bio::NeXML::IntRootEdge        
        
        floatnetwork = trees.create_network
        assert floatnetwork.kind_of? Bio::NeXML::Tree
        assert floatnetwork.kind_of? Bio::Tree
        assert floatnetwork.kind_of? Bio::NeXML::FloatNetwork
        floatnedge = floatnetwork.create_edge
        assert floatnedge.kind_of? Bio::NeXML::Edge
        assert floatnedge.kind_of? Bio::Tree::Edge
        assert floatnedge.kind_of? Bio::NeXML::FloatEdge
        
        intnetwork = trees.create_network( true )
        assert intnetwork.kind_of? Bio::NeXML::Tree
        assert intnetwork.kind_of? Bio::Tree
        assert intnetwork.kind_of? Bio::NeXML::IntNetwork
        intnedge = intnetwork.create_edge
        assert intnedge.kind_of? Bio::NeXML::Edge
        assert intnedge.kind_of? Bio::Tree::Edge
        assert intnedge.kind_of? Bio::NeXML::IntEdge        
      end
      def test_characters_seqs
        otu = @otus.create_otu
        dnaseqs = @nexml.create_characters( "Dna", false, :otus => @otus )
        assert dnaseqs.kind_of? Bio::NeXML::Characters
        assert dnaseqs.kind_of? Bio::NeXML::Dna
        assert dnaseqs.kind_of? Bio::NeXML::DnaSeqs
        assert_equal @otus, dnaseqs.otus
        
        format = dnaseqs.create_format
        assert format.kind_of? Bio::NeXML::Format
        assert_equal format, dnaseqs.format
        
        matrix = dnaseqs.create_matrix
        assert matrix.kind_of? Bio::NeXML::Matrix
        assert matrix.kind_of? Bio::NeXML::SeqMatrix
        assert_equal matrix, dnaseqs.matrix
        
        row = matrix.create_row( :otu => otu )
        assert row.kind_of? Bio::NeXML::Row
        assert row.kind_of? Bio::NeXML::SeqRow
        assert_equal otu, row.otu
        
        seq = 'ACATGCAG'
        newrow = dnaseqs.create_raw( seq )
        assert_equal newrow.sequences.first.value, seq
      end
      def test_characters_cells
        otu1 = @otus.create_otu
        otu2 = @otus.create_otu
        standardcells = @nexml.create_characters( "Standard", true, :otus => @otus )
        newrow1 = standardcells.create_raw('1 2 3 4 5')
        newrow1.otu = otu1
        newrow2 = standardcells.create_raw('1 2 3 4 5')
        newrow2.otu = otu2
        assert_equal otu1, newrow1.otu
        assert_equal otu2, newrow2.otu
        assert newrow1.kind_of? Bio::NeXML::Row
        assert newrow1.kind_of? Bio::NeXML::CellRow
        assert standardcells.kind_of? Bio::NeXML::Characters
        assert standardcells.kind_of? Bio::NeXML::Standard
        assert standardcells.kind_of? Bio::NeXML::StandardCells
      end
    end
  end
end
