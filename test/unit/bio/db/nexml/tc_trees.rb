class TestNode < Test::Unit::TestCase
  def setup
    @otu = Bio::NeXML::Otu.new( 'o1' )
    @node = Bio::NeXML::Node.new( 'n1' )
    @node.otu = @otu
  end

  def test_id
    @node.id = 'foo'
    assert_equal( 'foo', @node.id )
  end

  def test_label
    @node.label = 'a node'
    assert_equal( 'a node', @node.label )
  end

  def test_root?
    assert( !@node.root? )
  end

  def test_root=
    @node.root = true
    assert( @node.root )
  end

  def test_otu
    otu = Bio::NeXML::Otu.new( 'o2' )
    @node.otu = otu

    assert_equal( otu, @node.otu )
    assert_equal( otu.id, @node.taxonomy_id )
    assert_equal( otu.nodes, [ @node ] )
  end

end

class TestEdge < Test::Unit::TestCase
  def setup
    @n1 = Bio::NeXML::Node.new( 'n1' )
    @n2 = Bio::NeXML::Node.new( 'n2' )
    @edge = Bio::NeXML::Edge.new( 'e1', :source => @n1, :target => @n2 )
  end

  def test_id
    @edge.id = 'e2'
    assert_equal( 'e2', @edge.id )
  end

  def test_label
    @edge.label = 'an edge'
    assert_equal( 'an edge', @edge.label )
  end

  def test_source
    n3 = Bio::NeXML::Node.new( 'n3' )
    @edge.source = n3
    assert_equal( n3, @edge.source )
  end

  def test_target
    n3 = Bio::NeXML::Node.new( 'n3' )
    @edge.target = n3
    assert_equal( n3, @edge.target )
  end

  def test_length
    @edge.length = 1
    assert_equal( 1, @edge.length )
  end
end

class TestRootEdge < TestEdge
  def setup
    @edge = Bio::NeXML::RootEdge.new( 're1', :target => @n1 )
  end

  def test_source
    assert !@re.respond_to?( :source= )
  end
end

class TestTree < Test::Unit::TestCase

  def setup
    @roots = %w|n1 n9|.map { |n| Bio::NeXML::Node.new( n, :root => true ) }
    @nodes = %w|n2 n3 n4 n5 n6 n7 n8|.map { |n| Bio::NeXML::Node.new( n ) }
    @nodes = @nodes + @roots

    @edges = %w|e12 e13 e34 e37 e45 e46 e78 e79|.map do |e|
      source = @nodes.find { |n| n.id == "n#{e[1,1]}" }
      target = @nodes.find { |n| n.id == "n#{e[2,1]}" }
      Bio::NeXML::Edge.new( e, :source => source, :target => target )
    end

    @re = Bio::NeXML::RootEdge.new( 're1', :target => @n1 )

    @tree = Bio::NeXML::Tree.new( 'tree1', :nodes => @nodes, :edges => @edges, :rootedge => @re )
  end

  def test_id
    assert_equal( 'tree1', @tree.id )
    @tree.id = 'tree2'
    assert_equal( 'tree2', @tree.id )
  end

  def test_label
    assert_nil( @tree.label )
    @tree.label = 'a tree'
    assert_equal( 'a tree', @tree.label )
  end

  def test_rootedge
    assert_equal( @re, @tree.rootedge )
    re = Bio::NeXML::RootEdge.new( 're2', :target => @n9 )
    @tree.rootedge = re
    assert_equal( re, @tree.rootedge )
  end

  def test_roots
    @roots.each do |r|
      assert @tree.roots.include?( r )
    end
  end

  def test_add_node
    node = Bio::NeXML::Node.new( 'node' )
    @tree.add_node( node )
    assert @tree.include?( node )
    assert_equal( @tree, node.tree )
  end

  def test_add_edge
    node1 = Bio::NeXML::Node.new( 'node1' )
    node2 = Bio::NeXML::Node.new( 'node2' )
    edge = Bio::NeXML::Edge.new( 'edge', :source => node1, :target => node2 )
    @tree << node1 << node2 << edge

    assert @tree.include?( edge )
    assert_equal( @tree, edge.tree )
  end

  def test_delete_node
    @tree.delete_node( @nodes[ 2 ] )
    assert !@tree.include?( @nodes[ 2 ] )
  end

  def test_delete_edge
    @tree.delete_edge( @edges[ 1 ] )
    assert !@tree.include?( @edges[ 1 ] )
  end

  def test_append_operator
    n10 = Bio::NeXML::Node.new( 'n10' )
    e9 = Bio::NeXML::Edge.new( 'e9', :source => @n9, :target => n10 )

    @tree << n10
    @tree << e9

    @tree.include?( n10 )
    @tree.include?( e9 )
  end

  def test_get_node_by_id
    assert_equal( @nodes[ 0 ], @tree.get_node_by_id( 'n2' ) )
  end

  def test_get_edge_by_id
    assert_equal( @edges[ 0 ], @tree.get_edge_by_id( 'e12' ) )
  end

  def test_hash_notation
    assert_equal( @nodes[ 0 ], @tree[ 'n2' ] )
    assert_equal( @edges[ 0 ], @tree[ 'e12' ] )
  end

  def test_has_node
    assert @tree.has_node?( 'n2' )
    assert !@tree.has_node?( 'foo' )
  end

  def test_has_edge
    assert @tree.has_edge?( 'e12' )
    assert !@tree.has_edge?( 'foo' )
  end

  def test_include
    assert @tree.include?( @nodes[ 0 ] )
    assert @tree.include?( @edges[ 0 ] )
  end

  def test_each_node
    c = 0
    @tree.each_node do |n|
      assert @tree.include?( n )
      c +=1
    end
    assert @tree.number_of_nodes, c
  end

  def test_each_node_with_id
    c = 0
    @tree.each_node_with_id do |i, n|
      assert @tree.include?( n )
      assert_equal( n.id, i )
      c +=1
    end
    assert @tree.number_of_nodes, c
  end

  def test_each_edge
    c = 0
    @tree.each_edge do |e|
      assert @tree.include?( e )
      c +=1
    end
    assert @tree.number_of_edges, c
  end

  def test_each_edge_with_id
    c = 0
    @tree.each_edge_with_id do |i, e|
      assert @tree.include?( e )
      assert_equal( e.id, i )
      c +=1
    end
    assert @tree.number_of_edges, c
  end
end #end class TestTree

class TestTrees < Test::Unit::TestCase

  def setup
    @otus = Bio::NeXML::Otus.new( 'o1' )
    @tree = Bio::NeXML::Tree.new( 't1' )
    @network = Bio::NeXML::Tree.new( 'n1' )
    @trees = Bio::NeXML::Trees.new( 'trees1', :label => 'Tree container' )
    @trees.add_tree( @tree )
    @trees.add_network( @network )
  end

  def test_id
    @trees.id = 'trees2'
    assert_equal( 'trees2', @trees.id )
  end

  def test_label
    @trees.label = 'Label changed'
    assert_equal( 'Label changed', @trees.label )
  end

  def test_hash_notation
    assert_equal( @trees[ 't1' ], @tree )
    assert_equal( @trees[ 'n1' ], @network )
    assert_nil( @trees[ 'foo' ] )
  end

  def test_append_operator
    tree = Bio::NeXML::Tree.new( 't2' )
    network = Bio::NeXML::Tree.new( 'n2' )

    @trees << tree << network

    assert( @trees.include?( tree ) )
    assert( @trees.include?( network ) )

    assert_equal( @trees, tree.trees )
    assert_equal( @trees, network.trees )
  end

  def test_trees
    assert_equal( [ @tree ], @trees.trees )
  end

  def test_network
    assert_equal( [ @network ], @trees.networks )
  end

  def test_add_tree
    tree = Bio::NeXML::Tree.new( 't2' )
    @trees << tree
    assert( @trees.include?( tree ) )
    assert_equal( @trees, tree.trees )
  end

  def test_add_network
    network = Bio::NeXML::Tree.new( 'n2' )
    @trees << network
    assert( @trees.include?( network ) )
    assert_equal( @trees, network.trees )
  end

  def test_has_tree?
    assert( @trees.has_tree?( @t1 ) )
    assert( @trees.has_tree?( 't1' ) )
  end

  def test_has_network?
    assert( @trees.has_network?( @n1 ) )
    assert( @trees.has_network?( 'n1' ) )
  end

  def test_include?
    assert( @trees.include?( 't1' ) )
    assert( @trees.include?( 'n1' ) )
    assert( !@trees.include?( 'foo' ) )
  end

  def test_number_of_trees
    assert_equal( 1, @trees.number_of_trees )
  end

  def test_number_of_networks
    assert_equal( 1, @trees.number_of_networks )
  end

  def test_count
    assert_equal 2, @trees.count
  end

  def test_get_tree_by_id
    assert_not_nil @trees.get_tree_by_id 't1'
    assert_nil @trees.get_tree_by_id 'foo'
  end

  def test_get_network_by_id
    assert_not_nil @trees.get_network_by_id 'n1'
    assert_nil @trees.get_network_by_id 'foo'
  end

  def test_each_tree
    c = 0
    @trees.each_tree {|t| c+=1 }
    assert_equal 1, c
  end

  def test_each_network
    c = 0
    @trees.each_network {|t| c+=1 }
    assert_equal 1, c
  end

  def test_each
    c = 0
    @trees.each {|t| c+=1 }
    assert_equal 2, c
  end

end #end class TestTrees

#class TestTree < Test::Unit::TestCase

  #def setup
    #@tree = Bio::NeXML::Tree.new 'tree'
  #end

  #def teardown
    #@tree = nil
  #end

  #def test_add_rootedge
    #target = Bio::NeXML::Node.new 'node1'
    #re = Bio::NeXML::RootEdge.new 're1', target, 2
    #@tree.add_rootedge re
    #assert @tree.rootedge
  #end

  #def test_target_cache
    #assert_instance_of Array, @tree.target_cache
  #end

#end
