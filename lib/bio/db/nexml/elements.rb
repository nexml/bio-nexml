require "../../tree"

module Bio
  module NeXML

    module Labelled

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
        @otu
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
      attr_accessor :otu

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

    end #end class Otus

    class Node < Bio::Tree::Node
      include TaxonLinked

      def initialize( id, label = nil )
        super()
        @id = id
        @label = label
      end

    end #end class Node

    class Edge < Bio::Tree::Edge
      include IDTagged

      def initialize( id, source, target, length = nil, label = nil )
        super()
        @id = id
        @label = label
      end

    end #end class Edge

    class Tree < Bio::Tree
      include IDTagged

      def initialize( id, label = nil )
        super()
        @id = id
        @label = label
      end

    end #end class Tree

    class Trees
      include TaxaLinked
      attr_accessor :tree

      def initialize( id, label = nil )
        @id = id
        @label = label
      end
    end #end class Trees

  end #end module NeXML

end #end module Bio
