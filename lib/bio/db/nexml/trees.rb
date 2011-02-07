require 'bio/tree'

module Bio
  module NeXML

    # Node represents a node of a Tree or a Network. A node must have a unique id. It may optionally
    # have a human readable 'label' and may link to an 'otu'.
    class Node < Bio::Tree::Node
      include Mapper
      @@writer = Bio::NeXML::Writer.new
      
      def to_xml
        @@writer.create_node( "node", @@writer.attributes( self, :id, :otu, :root, :label ) )
      end

      # A file level unique identifier.
      attr_accessor :id

      # Stores a boolean value to indicate a root node.
      attr_accessor :root

      # A human readable description.
      attr_accessor :label

      # A node may optionally refer to an Otu.
      belongs_to  :otu

      # A node is deemed part of a Tree.
      belongs_to  :tree

      # Create a new otu. Passing an 'id' is a must. While 'label' and 'otu' may be passed
      # as an optional hash.
      #    node = Bio::NeXML::Node.new( 'node1' )
      #    node = Bio::NeXML::Node.new( 'node1', :label => 'A node' )
      #    node = Bio::NeXML::Node.new( 'node1', :label => 'A node', :otu => otu )
      def initialize( id, options = {} )
        super( id )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Return the otu to which the node links to.
      def otu; end if false # dummy for rdoc

      # Link the node to the given otu.
      def otu=( otu ); end if false # dummy for rdoc

      # Returns true if the node is a root node; false otherwise.
      def root?
        root
      end
    end #end class Node

    # Edge connect two nodes of a tree or a network. An edge should have a unique id. It should have
    # a 'source' and a 'target' node and optionally a 'length' may be assigned to it.
    class Edge < Bio::Tree::Edge
      include Mapper
      @@writer = Bio::NeXML::Writer.new
      
      def to_xml
        @@writer.create_node( "edge", @@writer.attributes( self, :id, :source, :target, :length, :label ) )
      end

      # A file level unique identifier.
      attr_accessor :id

      # Source of the edge.
      attr_accessor :source

      # Target of the edge.
      attr_accessor :target

      # A human readable description.
      attr_accessor :label

      # A node is deemed part of a Tree.
      belongs_to :tree

      # Create a new edge.
      #    edge = Bio::NeXML::Edge.new( 'edge1' )
      #    edge = Bio::NeXML::Edge.new( 'edge1', :source => node1, :target => node2 )
      #    edge = Bio::NeXML::Edge.new( 'edge1', :source => node1, :target => node2, :length => 1 )
      def initialize( id, options = {} )
        super( length )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Return the length of an edge.
      def length
        distance
      end

      # Set the length of an edge.
      def length=( length )
        self.distance = length
      end
    end #end class Edge

    # A rootedge is an edge without a source. It is used in context of coalescent trees. RootEdge
    # inherits from Edge so the same functionality is available in rootedge too.
    class RootEdge < Edge
      @@writer = Bio::NeXML::Writer.new
      def to_xml
        @@writer.create_node( "rootedge", @@writer.attributes( self, :id, :target, :length, :label ) )
      end      
      
      private :source=

      def initialize( id, options = {} )
        super
      end
    end
    
    class FloatRootEdge < RootEdge
      def initialize( id, options = {} )
        super
      end
      def length
        distance.to_f
      end      
    end
    
    class IntRootEdge < RootEdge
      def initialize( id, options = {} )
        super
      end
      def length
        distance.to_i
      end      
    end    
    
    # A float edge is an edge whose length is defined using a floating point
    # number.
    class FloatEdge < Edge
      def initialize( id, options = {} )
        super
      end
      def length
        distance.to_f
      end
    end
    
    # An int edge is an edge whose length is defined using an integer
    class IntEdge < Edge
      def initialize( id, options = {} )
        super
      end
      def length
        distance.to_i
      end
    end

    # An NeXML tree. A tree must have a unique 'id'. It may optionally take a 'label' and a 'rootedge'.
    # This class inherits from Bio::Tree; naturally its functionality is leveraged here.
    class Tree < Bio::Tree
      include Mapper
      @@writer = Bio::NeXML::Writer.new
      
      def to_xml
        node = @@writer.create_node( "tree", @@writer.attributes( self, :id, :'xsi:type', :label ) )

        self.each_node do |n|
          node << n.to_xml
        end

        rootedge = self.rootedge
        node << rootedge.to_xml if rootedge

        self.each_edge do |edge|
          node << edge.to_xml
        end

        node
      end
      
      def create_node( options = {} )
        node = Node.new( Bio::NeXML.generate_id( Node ), options )
        self << node
        node        
      end
      
      def create_edge( options = {} )
        raise "This is supposed to be an abstract method"
      end
      
      def create_rootedge( options = {} )
        raise "This is supposed to be an abstract method"
      end

      # A file level unique identifier.
      attr_accessor :id

      # A human readable description.
      attr_accessor :label

      # A rootedge to indicate a time span leading up to the root.
      attr_accessor :rootedge

      # A tree is contained in Trees.
      belongs_to :trees

      # A tree will contain n number of nodes.
      has_n    :nodes
      
      # A tree will contain n number of edges joining the nodes.
      has_n    :edges

      # Create a new tree.
      #    tree = Bio::NeXML::Tree.new( 'tree1' )
      #    tree = Bio::NeXML::Tree.new( 'tree1', :label => 'A tree' )
      #
      #    nodes = %w|node1 node2 node3|.map{ |n| Bio::NeXML::Node.new( n ) }                
      #    edge1 = Bio::NeXML::Edge.new( 'edge1', :source => nodes[0], :target => nodes[1] )
      #    edge2 = Bio::NeXML::Edge.new( 'edge2', :source => nodes[0], :target => nodes[2] )
      #
      #    tree = Bio::NeXML::Tree.new( 'tree1', :nodes => nodes )
      #    tree = Bio::NeXML::Tree.new do |t|                                        
      #             t.label = 'A tree'
      #             t.nodes = nodes
      #             t.edges = [ edge1, edge2 ]
      #             # or, t << edge1 << edge2
      #             # or, t.add_edge( edge1 ); t.add_edge( edge2 )
      #
      #             root = Bio::NeXML::Node.new( 'root1', :root => true )
      #             rootedge = Bio::NeXML::RootEdge.new( 're1', :target => root )
      #
      #             t << root # or, t.add_otu( root )
      #             t.rootedge = rootedge
      #           end                                                                 
      def initialize( id = nil, options = {}, &block )
        super()
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Returns an array of root nodes.
      def roots
        nodes.select{ |n| n.root? }
      end

      # Append a node or an edge to the tree. The method delegates the actuall addition to
      # <tt>add_node</tt>, <tt>add_edge</tt> methods.
      def <<( object )
        case object
        when Node
          add_node( object )
        when Edge
          add_edge( object )
        end
        self
      end

      # :stopdoc:
      alias __add_node__ add_node
      # :startdoc:
      # Add a node to the tree.
      def add_node( node )
        super( node )
        __add_node__( node )
      end

      # :stopdoc:
      alias __add_edge__ add_edge
      # :startdoc:
      # Add an edge to the tree.
      def add_edge( edge )
        super( edge.source, edge.target, edge )
        __add_edge__( edge )
      end
      
      def add_rootedge( edge )
        @rootedge = edge
      end

      # :stopdoc:
      alias __delete_node__ delete_node
      # :startdoc:

      # Remove a node from the tree. Returns the deleted node. It automatically removes all edges
      # connected to that node. Raises IndexError if the node is not found in the tree.
      def remove_node( node )
        return unless include?( node )
        super( node )
        __delete_node__( node )
      end
      alias delete_node remove_node

      # :stopdoc:
      alias __delete_edge__ delete_edge
      # :startdoc:

      # Remove an edge from the tree. Returns the edge deleted. If more than one edge exists between
      # the source and the target, both of them will be removed. Raises IndexError if the edge is 
      # not found in the tree.
      def remove_edge( edge )
        return unless include?( edge )
        super( edge.source, edge.target )
        __delete_edge__( edge )
      end
      alias delete_edge remove_edge

      # Fetch a node by the given id.
      def get_node_by_id( id ); end if false # dummy for rdoc

      # get_node_by_name is actually defined in Bio::Tree. I have aliased it to get_node_by_id
      # as hash lookup is faster than searching through an enumerable.
      alias get_node_by_name get_node_by_id

      # Fetch an edge by the given id.
      def get_edge_by_id( id ); end if false # dummy for rdoc

      # Fetch a node, or an edge by its id.
      def []( id )
        get_node_by_id( id ) ||
          get_edge_by_id( id )
      end

      # Returns true if the given node is a part of <tt>self</tt>.
      def has_node?( node ); end if false # dummy for rdoc

      # Returns true if the given edge is a part of <tt>self</tt>.
      def has_edge?( edge ); end if false # dummy for rdoc

      # Returns true if the given node or the edge object is a part of this tree; false otherwise.
      def include?( object )
        has_node?( object ) ||
          has_edge?( object )
      end
      alias has? include?

      # Iterate over each node. Return an Enumerator if no block is given.
      def each_node( &block ); end if false # dummy for rdoc

      # Iterate over each node passing id and the node itself to the given block.
      # Returns an Enumerator if no block is given.
      def each_node_with_id; end if false # dummy for rdoc

      # Iterate over each edge. Return an Enumerator if no block is given.
      def each_edge; end if false # :yield: edge

      # Iterate over each node passing id and the node itself to the given block.
      # Returns an Enumerator if no block is given.
      def each_edge_with_id; end if false # dummy for rdoc

      # Return the number of nodes in the tree.
      def number_of_nodes; end if false #dummy for rdoc

      # Return the number of edges in the tree.
      def number_of_edges; end if false #dummy for rdoc

      # :stopdoc:
      # Following methods have been redifined from Bio::Tree to take advantage of multiple root
      # nodes in NeXML. Since for each root a differrent solution is possible, the result returned
      # is a ( root, solution) hash. The solution for each root is the same as that returned by its
      # super method.
      # :startdoc:

      # Returns the parent of the given node corresponding to each root.
      def parent( node, *roots )
        if roots.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.roots.empty?
          roots = self.roots
        end
        parents = {}
        roots.each do |r|
          parents[ r ] = super( node, r )
        end
        parents
      end

      def children( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        childrens = {}
        root.each do |r|
          c = adjacent_nodes(node)
          c.delete(parent(node, r)[ r ])
          childrens[ r ] = c
        end

        childrens
      end

      def descendents( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        descendent = {}
        root.each do |r|
          descendent[ r ] = super( node, r )
        end
        descendent
      end

      def lowest_common_ancestor( node1, node2, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        lca = {}
        root.each do |r|
          lca[ r ] = super( node1, node2, r )
        end
        lca
      end

      def ancestors( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        ancestor = {}
        root.each do |r|
          ancestor[ r ] = super( node, r )
        end
        ancestor
      end
    end #end class Tree

    class IntTree < Tree
      def initialize( id = nil, options = {}, &block )
        super
      end

      def add_edge( edge )
        edge.length = edge.length.to_i
        super
      end
      
      def create_edge( options = {} )
        edge = IntEdge.new( Bio::NeXML.generate_id( IntEdge ), options )
        self << edge
        edge        
      end
      
      def create_rootedge( options = {} )
        rootedge = IntRootEdge.new( Bio::NeXML.generate_id( IntRootEdge ), options )
        self << rootedge
        rootedge
      end
      
    end

    class FloatTree < Tree
      def initialize( id = nil, options = {}, &block )
        super
      end

      def add_edge( edge )
        edge.length = edge.length.to_f
        super
      end
      
      def create_edge( options = {} )
        edge = FloatEdge.new( Bio::NeXML.generate_id( FloatEdge ), options )
        self << edge
        edge        
      end
      
      def create_rootedge( options = {} )
        rootedge = FloatRootEdge.new( Bio::NeXML.generate_id( FloatRootEdge ), options )
        self << rootedge
        rootedge
      end      
      
    end

    class Network < Tree
      @@writer = Bio::NeXML::Writer.new
      belongs_to :trees
      def initialize( id, options = {}, &block )
        super
      end
      
      def to_xml
        node = @@writer.create_node( "network", @@writer.attributes( self, :id, :'xsi:type', :label ) )

        self.each_node do |n|
          node << n.to_xml
        end

        self.each_edge do |edge|
          node << edge.to_xml
        end

        node
      end      
    end

    class IntNetwork < Network
      def initialize( id, options = {}, &block )
        super
      end

      def add_edge( edge )
        edge.length = edge.length.to_i
        super
      end

      def create_edge( options = {} )
        edge = IntEdge.new( Bio::NeXML.generate_id( IntEdge ), options )
        self << edge
        edge        
      end      
      
    end

    class FloatNetwork < Network
      def initialize( id, options = {}, &block )
        super
      end

      def add_edge( edge )
        edge.length = edge.length.to_f
        super
      end
      
      def create_edge( options = {} )
        edge = FloatEdge.new( Bio::NeXML.generate_id( FloatEdge ), options )
        self << edge
        edge        
      end      
      
    end

    class Trees
      include Mapper
      @@writer = Bio::NeXML::Writer.new
      
      def to_xml
        node = @@writer.create_node( "trees", @@writer.attributes( self, :id, :label, :otus ) )

        self.each_tree do |tree|
          node << tree.to_xml
        end

        self.each_network do |network|
          node << network.to_xml
        end

        node
      end
      
      def create_tree( int = false, options = {} )
        type = int ? Bio::NeXML::IntTree : Bio::NeXML::FloatTree
        tree = type.new( Bio::NeXML.generate_id( type ), options )
        self << tree
        tree
      end
      
      def create_network( int = false, options = {} )
        type = int ? Bio::NeXML::IntNetwork : Bio::NeXML::FloatNetwork
        network = type.new( Bio::NeXML.generate_id( type ), options )
        self << network
        network
      end      

      attr_accessor     :id
      attr_accessor     :label

      # A trees refers links to an otu.
      belongs_to   :otus

      # Trees is a container for trees and networks.
      has_n        :trees
      has_n        :networks

      belongs_to   :nexml

      # Create a trees object.
      def initialize( id = nil, options = {}, &block )
        @id = id
        properties( options ) unless options.empty?
        block.arity < 1 ? instance_eval( &block ) : block.call( self ) if block_given?
      end

      # Add a tree to self.
      def add_tree; end if false # dummy for rdoc

      # Add a networ to self.
      def add_network; end if false # dummy for rdoc

      # Add a tree or a network to self.
      def <<( object )
        case object
        when Network
          add_network( object )
        when Tree
          add_tree( object )
        end
        self
      end

      # Delete a tree from self.
      def delete_tree; end if false # dummy for rdoc

      # Delete a network from self.
      def delete_network; end if false # dummy for rdoc

      # Fetch a tree by id.
      def get_tree_by_id; end if false # dummy for rdoc

      # Fetch a network by id.
      def get_network_by_id; end if false # dummy for rdoc

      # Fetch a tree or a network by id.
      def []( id )
        get_tree_by_id( id ) ||
          get_network_by_id( id )
      end

      # Returns true if tree is containes in self.
      def has_tree?( tree ); end if false # dummy for rdoc

      # Returns true if the given network is containes in self; false otherwise.
      def has_network?( tree ); end if false # dummy for rdoc

      def include?( object )
        has_tree?( object ) ||
          has_network?( object )
      end
      alias has? include?

      # Returns the number of trees contained in self.
      def number_of_trees; end if false # dummy for rdoc

      # Returns the number of networks contained in self.
      def number_of_networks; end if false # dummy for rdoc

      # Returns total number of trees and networks.
      def count
        number_of_trees + number_of_networks
      end
      alias length count

      # Iterate over each tree. Returns an Enumerator if no block is given.
      def each_tree( &block ); end if false # dummy for rdoc

      # Iterate over each tree passing the id and the tree itself to the block.
      # Returns an Enumerator if no block is given.
      def each_tree_with_id( &block ); end if false # dummy for rdoc

      # Iterate over each network. Returns an Enumerator if no block is given.
      def each_network( &block ); end if false # dummy for rdoc

      # Iterate over each network passing the id and the tree itself to the block.
      # Returns an Enumerator if no block is given.
      def each_network_with_id( &block ); end if false # dummy for rdoc

      # Iterate over each element. Returns an Enumerator if no block is given.
      def each( &block )
        @trees.merge( @networks ).each( &block )
      end
    end #end class Trees
  end #end module NeXML
end #end module Bio
