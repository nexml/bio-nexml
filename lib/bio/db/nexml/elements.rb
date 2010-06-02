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
      #attr_accessor :otus_set, :trees_set, :characters_set
      
      def initialize( version, generator = nil )
        @version = version
        @generator = generator
      end

      def id_hash
        @id_hash ||= {}
      end

      def otus
        @otus_set ||= []
      end

      def trees
        @trees_set ||= []
      end

      def characters
        @characters_set
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
      #attr_accessor :otu

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      def otu
        @otu_set ||= []
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
      attr_accessor :source, :target

      def initialize( id, source, target, length = nil, label = nil )
        super()
        @id = id
        @label = label
        @source = source
        @target = target
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

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      def tree
        @tree_set ||= []
      end

    end #end class Trees

  end #end module NeXML

end #end module Bio
