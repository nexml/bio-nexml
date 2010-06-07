module Bio
  module NeXML

    module Base
      def xml_base
        @xml_base
      end

      def xml_base=( base )
        @xml_base = base
      end

      def xml_id
        @xml_id
      end

      def xml_id=( id )
        @xml_id = id
      end

      def xml_lang
        @xml_lang
      end

      def xml_lang=( lang )
        @xml_lang = lang
      end

      def xml_space
        @xml_space
      end

      def xml_space=( space )
        @xml_space = space
      end

      #xlink:href not done yet

    end #end module Base

    module Annotated
      include Base
    end

    class Nexml
      include Annotated
      include Enumerable
      attr_accessor :version, :generator
      
      def initialize( version, generator = nil )
        @version = version
        @generator = generator
      end

      def <<( element )
        case element
        when Otus
          add_otus element
        when Trees
          add_trees element
        end
      end

      #Return a hash of 'otus' objects or an empty hash
      #if no 'otus' object has been created yet.
      def otus_set
        @otus_set ||= {}
      end

      #Return a hash of 'trees' objects or an empty hash
      #if no 'trees' object has been created yet.
      def trees_set
        @trees_set ||= {}
      end

      #Add an 'otus' object.
      def add_otus( otus )
        otus_set[ otus.id ] = otus
      end
      
      #Add a 'trees' object.
      def add_trees( trees )
        trees_set[ trees.id ] = trees
      end

      #Iterate over each 'otus' object.
      def each_otus
        otus_set.each_value do |otus|
          yield otus
        end
      end
      
      #Iterate over each 'trees' object.
      def each_trees
        trees_set.each_value do |trees|
          yield trees
        end
      end

      #Iterate over each 'tree' object.
      def each
        trees_set.each_value do |trees|
          trees.each{ |tree| yield tree }
        end
      end

      #Return an 'otus' object with the given id or nil
      #if the 'otus' is not found.
      def get_otus_by_id( id )
        otus_set[ id ]
      end

      #Return an 'otu' object with the given id or nil
      #if the 'otu' is not found.
      def get_otu_by_id( id )
        otus_set.each_value do |otus|
          return otus[ id ] if otus.has_otu? id
        end
        
        nil
      end

      #Return an 'trees' object with the given id or nil.
      def get_trees_by_id( id )
        trees_set[ id ]
      end

      #Return a 'tree' object with the given id or nil.
      def get_tree_by_id( id )
        trees_set.each_value do |trees|
          return trees[ id ] if trees.has? id
        end
      end

      #Return an array of 'otus' objects.
      def otus
        otus_set.values
      end

      #Return an array of 'trees' objects.
      def trees
        trees_set.values
      end

      def characters
      end

    end #end class Nexml

    module Labelled
      include Annotated

      def label
        @label
      end
      
      def label=( label )
        @label = label
      end

    end #end module Labelled

    module IDTagged
      include Labelled

      def id
        @id
      end
      
      def id=( id )
        @id = id
      end

    end #end module IDTagged

    module TaxaLinked
      include IDTagged

      def otus
        @otus
      end

      def otus=( otus )
        @otus = otus
      end

    end #end module TaxaLinked

    module TaxonLinked
      include IDTagged

      def otu
        @otu
      end

      def otu=( otu )
        @otu = otu
      end

    end #end module TaxonLinked

    class Otu
      include IDTagged

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

    end #end class Otu

    class Otus
      include IDTagged
      include Enumerable

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      #Return a hash of 'otu' objects or
      #an empty hash if no 'otu' object created yet.
      def otu_set
        @otu_set ||= {}
      end

      #Return an array of 'otu' objects.
      def otus
        otu_set.values
      end

      #Iterate over all 'otu' object.
      def each
        @otu_set.each_value do |otu|
          yield otu
        end
      end
      alias :each_otu :each

      #Use array notation to access an 'otu'
      def []( key )
        otu_set[ key ]
      end

      #Checks if this 'otus' contains an 'otu'
      #with the given id.
      def has_otu?( id )
        otu_set.has_key? id
      end
      alias include? has_otu?

      #Add an 'otu' to this 'otus'
      def <<( otu )
        otu_set[ otu.id ] = otu
      end
      alias add_otu <<

    end #end class Otus

    class Node < Bio::Tree::Node
      include TaxonLinked
      attr_writer :root

      def initialize( id, label = nil, otu = nil, root = false )
        #use id for node's name
        super id
        @id = id
        @label = label
        #this is a little confusing
        #does not call otu= if self is not use
        self.otu = otu if otu
        @root = root
      end

      #Assign an otu to a node.
      def otu=( otu )
        @otu = otu
        taxonomy_id = otu.id
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
        distance
      end

      def length=( length )
        distance = length
      end

    end #end class Edge

    class IntEdge < Edge

      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_i
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

      #Add an edge to the tree.
      def add_edge( edge )
        edge_set[ edge.id ] = edge
        source = get_node_by_name( edge.source )
        target = get_node_by_name( edge.target )
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

      def initialize( id, label = nil, otus = nil )
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

  end #end module NeXML

end #end module Bio
