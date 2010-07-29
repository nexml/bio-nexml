module Bio
  module NeXML
    # = DESCRIPTION
    # Concrete implementation of <em>Taxon</em>[http://nexml.org/nexml/html/doc/schema-1/taxa/taxa/#Taxon] type.
    class Otu
      include IDTagged

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

    end #end class Otu

    # = DESCRIPTION
    # Concrete implementation of <em>Taxa</em>[http://nexml.org/nexml/html/doc/schema-1/taxa/taxa/#Taxa] type.
    class Otus
      include IDTagged
      include Enumerable

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      # Provide a hash storage for <em>otu</em> elements.
      # ---
      # *Returns*: a hash of Bio::NeXML::Otu objects or an empty hash
      # if none exist.
      def otu_set
        @otu_set ||= {}
      end

      # *Returns*: an array of Bio::NeXML::Otu objects.
      def otus
        otu_set.values
      end

      # Call the block for each <em>otu</em> element in <tt>self</tt> passing that object as a parameter.
      def each
        otu_set.each_value do |otu|
          yield otu
        end
      end
      alias :each_otu :each

      # Access <em>otu</em> using the hash notation.
      # ---
      # *Arguments*:
      # * id( required ) - id of the <em>otu</em> element to be accessed.
      # *Returns*: the <em>otu</em> element if found, nil otherwise.
      def []( key )
        otu_set[ key ]
      end
      alias get_otu_by_id []

      # Determine if a <em>otu</em> element belongs to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * id( required ) - id of the <em>otu</em> element to be checked.
      # *Returns*: true if the <em>otu</em> element is found, false otherwise.
      def has_otu?( id )
        otu_set.has_key? id
      end
      alias has? has_otu?
      alias include? has_otu?

      # Add <em>otu</em> elements to <tt>self</tt>. It delegates the addition of an individual <em>otu</em> to 
      # <tt>add_otu</tt> method.
      # ---
      # *Arguments*:
      # * otus( required ) - one or more( comma seperated ) Bio::NeXML::Otu objects.
      def <<( otus )
        if otus.instance_of? Array
          otus.each{ |otu| add_otu otu }
        else
          add_otu otus
        end
      end
      alias otus= <<

      # Add a single <em>otu</em> element to <tt>self</tt>.
      # ---
      # *Arguments*:
      # * otu( required ) - a Bio::NeXML::Otu object.
      def add_otu( otu )
        otu_set[ otu.id ] = otu
      end

    end #end class Otus

  end
end
