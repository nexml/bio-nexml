require 'bio/tree'

module Bio
  module NeXML

    class Node < Bio::Tree::Node
      include TaxonLinked
      attr_writer :root

      def initialize( id, otu = nil, root = false, label = nil )
        #use id for node's name
        super id
        @id = id
        @label = label
        self.otu = otu if otu
        @root = root
      end

      #Assign an otu to a node.
      def otu=( otu )
        @otu = otu
        self.taxonomy_id = otu.id
      end

      #Is it a root node?
      def root?
        @root
      end

    end #end class Node

    class Edge < Bio::Tree::Edge
      include IDTagged
      attr_accessor :source, :target

      def initialize( id, source, target, length = nil, label = nil )
        super length
        @id = id
        @label = label
        @source = source
        @target = target
      end

      def length
        self.distance
      end

      def length=( length )
        self.distance = length
      end

    end #end class Edge

    class IntEdge < Edge

      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_i if length
        super
      end

    end #end class IntEdge

    class FloatEdge < Edge
      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_f
        super
      end
    end #end class FloatEdge

    class RootEdge < Edge
      def initialize( id, target, length = nil, label = nil )
        super( id, nil, target, length, label )
      end
    end

    class AbstractTree < Bio::Tree
      include IDTagged

      def initialize( id, label = nil )
        super()
        @id = id
        @label = label
      end

      def root
        @root ||= []
      end

      def node_set
        @node_set ||= {}
      end

      def edge_set
        @edge_set ||= {}
      end

      def get_node_by_id( id )
        node_set[ id ]
      end
      alias get_node_by_name get_node_by_id

      def get_edge_by_id( id )
        edge_set[ id ]
      end

      def add_node( node )
        node_set[ node.id ] = node
        super
      end

      def nodes
        node_set.values
      end

      alias extended_edges edges
      def edges
        edge_set.values
      end

      def each_edge
        edge_set.each_value{ |edge| yield edge }
      end

      #Add an edge to the tree.
      def add_edge( edge )
        edge_set[ edge.id ] = edge
        source = edge.source
        target = edge.target
        super source, target, edge
      end

    end

    class Tree < AbstractTree
      attr_accessor :rootedge

      def initialize( id, label = nil )
        super
      end

      #Add a rootedge to the tree
      def add_rootedge( edge )
        self.rootedge = edge
      end

      def target_cache
        @target_cache ||= []
      end

      def add_edge( edge )
        target = edge.target
        raise "Target exists." if target_cache.include? target
        target_cache << target
        super
      end

      def parent( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        parents = {}
        root.each do |r|
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

    class IntTree < Tree ; end
    class FloatTree < Tree ; end

    class Network < AbstractTree

      def initialize( id, label = nil )
        super
      end

    end

    class IntNetwork < Network; end
    class FloatNetwork < Network; end

    class Trees
      include TaxaLinked
      include Enumerable

      def initialize( id, otus, label = nil )
        @id = id
        @label = label
        @otus = otus
      end

      #Access child tree objects with a hash like notation
      #given its id.
      def []( id )
        tree_set[ id ] or network_set[ id ]
      end

      #Iterate over child elements, i.e. all the
      #'tree' and 'network' object.
      def each
        tree_set.each_value do |tree|
          yield tree
        end
        network_set.each_value do |network|
          yield network
        end
      end

      #Add a 'tree' or a 'network'.
      def <<( element )
        #order of the when clause matters here
        #as a network is a tree too.
        case element
        when Network
          add_network element
        when Tree
          add_tree element
        end
      end

      #Returns a hash of 'tree' objects or
      #an empty hash if none exists.
      def tree_set
        @tree_set ||= {}
      end

      #Returns a hash of 'network' objects or
      #an empty hash if none exists.
      def network_set
        @network_set ||= {}
      end

      def add_network( netowrk )
        network_set[ netowrk.id ] = netowrk
      end

      def add_tree( tree )
        tree_set[ tree.id ] = tree
      end

      #Return an array of 'tree' objects.
      def trees
        tree_set.values
      end

      #Return an array of 'network' objects.
      def networks
        network_set.values
      end

      #Iterate over each 'tree' object.
      def each_tree
        tree_set.each_value do |tree|
          yield tree
        end
      end

      #Iterate over each 'network' object.
      def each_network
        network_set.each_value do |network|
          yield network
        end
      end

      #Find if a 'tree' with the given id exists
      #or not.
      def has_tree?( id )
        tree_set.has_key? id
      end

      #Find if a 'network' with the given id exists
      #or not.
      def has_network?( id )
        network_set.has_key? id
      end

      def has?( id )
        has_tree?( id ) or has_network?( id )
      end
      alias include? has?

      def number_of_trees
        tree_set.length
      end

      def number_of_networks
        network_set.length
      end

      def number_of_graphs
        number_of_trees + number_of_networks
      end

      def get_tree_by_id( id )
        tree_set[ id ]
      end

      def get_network_by_id( id )
        network_set[ id ]
      end

    end #end class Trees

  end
end
