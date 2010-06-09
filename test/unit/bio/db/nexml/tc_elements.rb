module Bio
  module NeXML

    class TestNexml < Test::Unit::TestCase

      def setup
        @nexml = Bio::NeXML::Nexml.new 0.9
      end

      def teardown
        @nexml = nil
      end

      def test_is_enumerable
        @nexml.class.ancestors.include? Enumerable
      end

      def test_otus_set
        assert_instance_of Hash, @nexml.otus_set
      end

      def test_trees_set
        assert_instance_of Hash, @nexml.trees_set
      end

      def test_otus
        assert_instance_of Array, @nexml.otus
      end

      def test_trees
        assert_instance_of Array, @nexml.trees
      end

      def test_add_otus
        assert_send [@nexml.otus_set, :empty?]

        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        not_empty = !@nexml.otus_set.empty?
        assert not_empty
      end

      def test_add_trees
        assert_send [@nexml.trees_set, :empty?]

        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees
        
        not_empty = !@nexml.trees_set.empty?
        assert not_empty
      end

      def test_append
        assert_send [@nexml.trees_set, :empty?]

        trees = Bio::NeXML::Trees.new 'trees'
        @nexml << trees
        
        not_empty = !@nexml.trees_set.empty?
        assert not_empty
      end

      def test_each_otus
        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        @nexml.each do |o|
          assert_not_nil o.id
        end
      end

      def test_each_trees
        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees

        @nexml.each do |t|
          assert_not_nil t.id
        end
      end

      def test_each
        tree = Bio::NeXML::IntTree.new 'tree'
        trees = Bio::NeXML::Trees.new 'trees'
        trees << tree
        @nexml << trees

        @nexml.each do |t|
          assert_not_nil t.id
        end
      end

      def test_get_otus_by_id
        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        assert @nexml.get_otus_by_id 'otus'
      end

      def test_get_otu_by_id
        otu = Bio::NeXML::Otu.new 'otu'
        otus = Bio::NeXML::Otus.new 'otus'
        otus << otu
        @nexml << otus

        assert @nexml.get_otu_by_id 'otu'
      end

      def test_get_trees_by_id
        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees

        assert @nexml.get_trees_by_id 'trees'
      end

      def test_get_tree_by_id
        tree = Bio::NeXML::IntTree.new 'tree'
        trees = Bio::NeXML::Trees.new 'trees'
        trees << tree
        @nexml << trees

        assert @nexml.get_tree_by_id 'tree'
      end

    end #end class TestNexml

    class TestIDTagged < Test::Unit::TestCase

      class IDTagged
        include Bio::NeXML::IDTagged
      end

      def setup
        @idtagged = IDTagged.new
      end

      def test_id
        assert_nil( @idtagged.id )
      end

      def test_id=
        @idtagged.id = "id"
        assert_equal "id", @idtagged.id
      end

    end

    class TestLabelled < Test::Unit::TestCase
      class Labelled
        include Bio::NeXML::Labelled
      end

      def setup
        @labelled = Labelled.new
      end

      def test_label
        assert_nil @labelled.label
      end

      def test_label=
        @labelled.label = "Test Label"
        assert_equal "Test Label", @labelled.label
      end
    end

    class TestOtu < Test::Unit::TestCase

      def setup
        @otu = Bio::NeXML::Otu.new 'otu1'
      end

      def teardown
        @otu = nil
      end

      def test_is_idtagged
        @otu.class.ancestors.include? Bio::NeXML::IDTagged
      end

      def test_is_labelled
        @otu.class.ancestors.include? Bio::NeXML::Labelled
      end

    end #end class TestOtu

    class TestOtus < Test::Unit::TestCase

      def setup
        @otus = Bio::NeXML::Otus.new "otus1"
      end

      def teardown
        @otus = nil
      end

      def test_is_idtagged
        @otus.class.ancestors.include? Bio::NeXML::IDTagged
      end

      def test_is_labelled
        @otus.class.ancestors.include? Bio::NeXML::Labelled
      end

      def test_is_enumerable
        @otus.class.ancestors.include? Enumerable
      end

      def test_otu_set
        assert_instance_of Hash, @otus.otu_set
      end

      def test_otus
        assert_instance_of Array, @otus.otus
      end

      def test_add_otu
        assert_send [@otus.otu_set, :empty?]
        assert_send [@otus.otus, :empty?]

        otu = Bio::NeXML::Otu.new 'otu2'
        @otus << otu

        not_empty = !@otus.otu_set.empty?
        assert not_empty

        not_empty = !@otus.otus.empty?
        assert not_empty
      end

      def test_has_otu?
        otu = Bio::NeXML::Otu.new 'otu3'
        @otus << otu

        assert @otus.has_otu? 'otu3'
      end

      def test_hash_notation
        otu = Bio::NeXML::Otu.new 'otu4'
        @otus << otu

        assert @otus[ 'otu4' ]
      end

      def test_each
        otu5 = Bio::NeXML::Otu.new 'otu5'
        @otus << otu5

        otu6 = Bio::NeXML::Otu.new 'otu6'
        @otus << otu6

        @otus.each do |o|
          assert_not_nil o.id
        end
      end

    end #end class TestOtus

    class TestNode < Test::Unit::TestCase

      def setup
        @node = Bio::NeXML::Node.new 'node1'
      end
    
      def teardown
        @node = nil
      end

      def test_otu=
        assert_nil @node.otu

        otu = Bio::NeXML::Otu.new 'otu1'
        @node.otu = otu

        assert_not_nil @node.otu
        assert_equal @node.taxonomy_id, otu.id
      end

      def test_root?
        @node.root = true
        assert @node.root?
      end
    
    end #end class TestNode

    class TestEdge < Test::Unit::TestCase

      def setup
        target = Bio::NeXML::Node.new 'target'
        source = Bio::NeXML::Node.new 'source'
        @edge = Bio::NeXML::Edge.new 'edge1', source, target, 1
      end

      def teardown
        @edge = nil
      end

      def test_length
        assert_equal @edge.length, 1
      end

      def test_length=
        @edge.length = 2
        assert_equal @edge.length, 2
      end 

    end

    class TestTrees < Test::Unit::TestCase

      def setup
        @trees = Bio::NeXML::Trees.new 'trees1'
      end

      def teardown
        @trees = nil
      end

      def test_hash_notation
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees << tree
        assert_not_nil @trees[ 'tree1' ]
      end

      def test_tree_set
        assert_instance_of Hash, @trees.tree_set
      end

      def test_network_set
        assert_instance_of Hash, @trees.network_set
      end

      def test_trees
        assert_instance_of Array, @trees.trees
      end

      def test_networks
        assert_instance_of Array, @trees.networks
      end

      def test_add_tree
        assert_send [@trees.tree_set, :empty?]

        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree

        not_empty = !@trees.tree_set.empty?
        assert not_empty
      end

      def test_add_network
        assert_send [@trees.network_set, :empty?]

        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network

        not_empty = !@trees.network_set.empty?
        assert not_empty
      end

      def test_has_tree?
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        assert @trees.has_tree? tree.id
      end

      def test_has_network?
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        assert @trees.has_network? network.id
      end

      def test_has?
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        assert @trees.has_network? network.id
      end
    
      def test_number_of_trees
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        assert_equal 1, @trees.number_of_trees
      end

      def test_number_of_networks
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        assert_equal 1, @trees.number_of_networks
      end

      def test_number_of_graphs
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        assert_equal 2, @trees.number_of_graphs
      end

      def test_get_tree_by_id
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        assert_not_nil @trees.get_tree_by_id 'tree1'
      end

      def test_get_network_by_id
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        assert_not_nil @trees.get_network_by_id 'network1'
      end

      def test_each_tree
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        c = 0
        @trees.each_tree {|t| c+=1 }
        assert_equal 1, c
      end

      def test_each_network
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        c = 0
        @trees.each_network {|t| c+=1 }
        assert_equal 1, c
      end

      def test_each
        tree = Bio::NeXML::Tree.new 'tree1'
        @trees.add_tree tree
        network = Bio::NeXML::Network.new 'network1'
        @trees.add_network network
        c = 0
        @trees.each {|t| c+=1 }
        assert_equal 2, c
      end

    end #end class TestTrees

    class TestAbstractTree < Test::Unit::TestCase

      def setup
        @atree = Bio::NeXML::AbstractTree.new 'tree'
      end

      def teardown
        @atree = nil
      end

      def test_root
        assert_instance_of Array, @atree.root
      end

      def test_node_set
        assert_instance_of Hash, @atree.node_set
      end

      def test_edge_set
        assert_instance_of Hash, @atree.edge_set
      end

      def test_add_node
        assert_send [@atree.node_set, :empty?]

        node = Bio::NeXML::Node.new 'node1'
        @atree.add_node node

        not_empty = !@atree.node_set.empty?
        assert not_empty
      end

      def test_add_edge
        assert_send [@atree.edge_set, :empty?]

        source = Bio::NeXML::Node.new 'node1'
        target = Bio::NeXML::Node.new 'node2'
        edge = Bio::NeXML::Edge.new 'e1', source, target, 1
        @atree.add_edge edge

        not_empty = !@atree.edge_set.empty?
        assert not_empty
      end

      def test_get_node_by_id
        node = Bio::NeXML::Node.new 'node1'
        @atree.add_node node

        assert @atree.get_node_by_id 'node1'
      end

      def test_get_edge_by_id
        source = Bio::NeXML::Node.new 'node1'
        target = Bio::NeXML::Node.new 'node2'
        edge = Bio::NeXML::Edge.new 'e1', source, target, 1
        @atree.add_edge edge

        assert @atree.get_edge_by_id 'e1'
      end

    end #end class TestTree

    class TestTree < Test::Unit::TestCase

      def setup
        @tree = Bio::NeXML::Tree.new 'tree'
      end

      def teardown
        @tree = nil
      end

      def test_add_rootedge
        target = Bio::NeXML::Node.new 'node1'
        re = Bio::NeXML::RootEdge.new 're1', target, 2
        @tree.add_rootedge re
        assert @tree.rootedge
      end

      def test_target_cache
        assert_instance_of Array, @tree.target_cache
      end

    end

  end #end module NeXML

end #end module Bio
