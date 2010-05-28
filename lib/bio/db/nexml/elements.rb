module Bio
  module NeXML
    class Otus
      attr_accessor :id, :label

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      def otu
        @otu ||= []
      end

    end #end class otus

    class Otu
      attr_accessor :id, :label

      def initialize( id, label = nil )
        @id = id
        @label = label
      end
    end #end class otu

  end

end
