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
      attr_accessor :version, :generator
      
      def initialize( version, generator = nil )
        @version = version
        @generator = generator
      end

      #Return a hash of 'otus' objects or an empty hash
      #if no 'otus' object has been created yet.
      def otus_set
        @otus_set ||= {}
      end

      #Return an array of 'otus' objects.
      def otus
        otus_set.values
      end

      #Iterate over each 'otus' object.
      def each_otus
        otus_set.each_value do |otus|
          yield otus
        end
      end

      #Return an 'otus' object with the given id or nil
      #if the 'otus' is not found.
      def get_otus_by_id( id )
        otus_set[ id ]
      end

      #Add an 'otus' object.
      def add_otus( otus )
        otus_set[ otus.id ] = otus
      end

      #Return an 'otu' object with the given id or nil
      #if the 'otu' is not found.
      def get_otu_by_id( id )
        each_otus do |otus|
          return otus[ id ] if otus.has_otu? id
        end
        
        nil
      end

      #Return a hash of 'trees' objects or an empty hash
      #if no 'trees' object has been created yet.
      def trees_set
        @trees_set ||= {}
      end

      #Return an array of 'trees' objects.
      def trees
        trees_set.values
      end

      #Iterate over each 'trees' object.
      def each_trees
        trees.each do |trees|
          yield trees
        end
      end

      #Return an 'trees' object with the given id or nil.
      def get_trees_by_id( id )
        trees_set[ id ]
      end

      #Add a 'trees' object.
      def add_trees( trees )
        trees_set[ trees.id ] = trees
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
        @otu_set.values
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

      #Add an 'otu' to this 'otus'
      def <<( otu )
        otu_set[ otu.id ] = otu
      end

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
    end

    class FloatEdge < Edge
      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_f
        super
      end
    end

    class Tree < Bio::Tree
      include IDTagged

      def initialize( id, label = nil )
        super()
        @id = id
        @label = label
      end

      #Add an edge to the tree.
      def add_edge( edge )
        source = get_node_by_name( edge.source )
        target = get_node_by_name( edge.target )
        super source, target, edge
      end

    end #end class Tree

    class IntTree < Tree ; end
    class FloatTree < Tree ; end

    class Trees
      include TaxaLinked
      include Enumerable

      def initialize( id, label = nil, otus = nil )
        @id = id
        @label = label
        @otus = otus
      end

      def tree_set
        @tree_set ||= {}
      end

      #Add a 'tree'.
      def <<( tree )
        tree_set[ tree.id ] = tree
      end

      #Return an array of 'tree' objects.
      def trees
        tree_set.values
      end

      #Iterate over each 'tree' object.
      def each
        trees.each do |tree|
          yield tree
        end
      end
      alias each_tree each

      #Access child tree objects with a hash like notation
      #given its id.
      def []( id )
        tree_set[ id ]
      end

      def has_tree?( id )
        tree_set.has_key? id
      end
    end #end class Trees

  end #end module NeXML

end #end module Bio
