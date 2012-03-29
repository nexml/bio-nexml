require 'xml'
require 'bio/db/nexml/parser'
require 'bio/db/nexml/writer'
require 'bio/db/nexml/mapper'
require 'bio/db/nexml/taxa'
require 'bio/db/nexml/trees'
require 'bio/db/nexml/matrix'

module Bio
  module NeXML
    
    @@id_counter = 0;
    def self.generate_id( klass )
      myname = klass.name
      local = myname.gsub(/.*:/,"")
      @@id_counter += 1
      newid = @@id_counter
      "#{local}#{newid}"
    end    

    module Base
      attr_accessor :xml_base
      attr_accessor :xml_id
      attr_accessor :xml_lang
      attr_accessor :xml_space
    end #end module Base

    class Nexml
      @@writer = Bio::NeXML::Writer.new      
      include Mapper
      include Enumerable
      attr_accessor :version
      attr_accessor :generator

      has_n :otus,       :singularize => false
      has_n :trees,      :singularize => false
      has_n :characters, :singularize => false
      
      def initialize( version = '0.9', generator = 'bioruby' )
        @version = version
        @generator = generator
      end

      # Append a Otus, Trees, or Characters object to any
      # Nexml object.
      def <<( element )
        case element
        when Otus
          add_otus element
        when Trees
          add_trees element
        when Characters
          add_characters element
        end
      end
      
      def create_otus( options = {} )
        otus = Otus.new( Bio::NeXML.generate_id( Otus ), options )
        self << otus
        otus        
      end
      
      def create_trees( options )
        trees = Trees.new( Bio::NeXML.generate_id( Trees ), options )
        self << trees
        trees
      end
      
      def create_characters( type = "Dna", verbose = false, options = {} )
        subtype = verbose ? "Cells" : "Seqs"
        klass_name = "#{type.to_s.capitalize}#{subtype}"
        klass = NeXML.const_get( klass_name )
        characters = klass.new( Bio::NeXML.generate_id( klass ), options )
        self << characters
        characters
      end
      
      def to_xml
        node = @@writer.create_node( "nex:nexml", :"xsi:schemaLocation" => "http://www.nexml.org/2009 http://www.nexml.org/2009/xsd/nexml.xsd", :generator => generator, :version => version )
        node.namespaces = { nil => "http://www.nexml.org/2009", :xsi => "http://www.w3.org/2001/XMLSchema-instance", :xlink => "http://www.w3.org/1999/xlink", :nex => "http://www.nexml.org/2009" }
        self.each_otus do |otus|
            node << otus.to_xml
        end
        self.each_characters do |characters|
            node << characters.to_xml
        end
        self.each_trees do |trees|
            node << trees.to_xml
        end        
        node
      end      
      
    end #end class Nexml
  end
end

