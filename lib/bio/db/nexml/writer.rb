module Bio
  module NeXML
    include LibXML

    class Writer

      def initialize( filename = nil, indent = true )
        @filename = filename
        @indent = indent
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

      def save( filename = nil, indent = false )
        filename ||= @filename
        indent ||= @indent
        @doc.save( filename, :indent => indent )
      end

      def write_otus( object )
        node = otus "id" => object.id, "label" => object.label

        object.each do |otu|
          node << serialize_otu( otu )
        end

        @root << node
      end

      def write_trees( object )
        node = trees "id" => object.id, "label" => object.label

        object.each do |tree|
          node << serialize_tree( tree )
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

      def serialize_tree( object )
        type = object.class.to_s
        node = tree "id" => object.id, "label" => object.label, "type" => type

        object.each_node do |n|
          node << serialize_node( n )
        end

        node << serialize_rootedge( object.rootedge ) if object.respond_to? :rootedge and object.rootedge

        object.each_edge do |edge|
          node << serialize_edge( edge )
        end

        node
      end

      def serialize_node( object )
        otu = object.otu.id if object.otu
        node "id" => object.id, "label" => object.label, "otu" => otu
      end

      def serialize_edge( object )
        edge "id" => object.id, "source" => object.source, "target" => object.target, "label" => object.label
      end

      def serialize_rootedge( object )
        rootedge "id" => object.id, "target" => object.source, "length" => object.length.to_s
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

      def tag( name, attributes = {} )
        node = XML::Node.new( name )
        add_attributes( node, attributes ) unless attributes.empty?
        node
      end
      alias method_missing tag

    end #end class Parser

  end #end module NeXML

end #end module Bio
