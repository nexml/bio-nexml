module Bio
  module NeXML
    include LibXML

    class Writer

      def initialize
        @doc = XML::Document.new
        @root = root
        @doc.root = @root
      end

      def <<( object )
        case object
        when Otus
          write_otus( object )
        when Trees
          write_trees( object )
        when Characters
          write_characters( object )
        end
      end

      def save( filename )
        @doc.save( filename, :indent => true )
      end

      def write_otus( object )
        node = otus "id" => object.id, "label" => object.label

        object.each do |otu|
          node << serialize_otu( otu )
        end

        @root << node
      end

      def root
        root = nexml "xsi::schemaLocation" => "http://www.nexml.org/1.0 ../xsd/nexml.xsd", "generator" => "bioruby", "version" => "0.9"
        add_namespaces root, nil => "http://www.nexml.org/1.0", "xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xlink" => "http://www.w3.org/1999/xlink", "nex" => "http://www.nexml.org/1.0"
        root
      end

      private

      def serialize_otu( object )
        otu "id" => object.id, "label" => object.label
      end

      def add_namespaces( node, namespaces )
        namespaces.each do |prefix, prefix_uri|
          XML::Namespace.new( node, prefix, prefix_uri )
        end
      end

      def add_attributes( node, attributes )
        attributes.each do |name, value|
          XML::Attr.new( node, name, value ) unless value.nil?
        end
      end

      def node( name, attributes = {} )
        node = XML::Node.new( name )
        add_attributes( node, attributes ) unless attributes.empty?
        node
      end
      alias method_missing node

    end #end class Parser

  end #end module NeXML

end #end module Bio
