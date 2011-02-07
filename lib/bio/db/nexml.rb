#load XML library for parser and serializer
require 'xml'

#load required class and module definitions
require "bio/db/nexml/mapper"

#Autoload definition
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

    # Autoload multiple modules that reside in the same file.
    def self.mautoload( modules, file )
      modules.each do |m|
        autoload m, file
      end
    end

    mautoload %w|Otu Otus|,                                'bio/db/nexml/taxa.rb'
    mautoload %w|Node Edge Tree Network Trees|,            'bio/db/nexml/trees.rb'
    mautoload %w|State Char States Cell Sequence Format Characters|,  'bio/db/nexml/matrix.rb'

    autoload :Parser, 'bio/db/nexml/parser'
    autoload :Writer, 'bio/db/nexml/writer'

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

