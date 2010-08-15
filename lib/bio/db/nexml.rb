#load XML library for parser and serializer
require 'xml'

#load required class and module definitions
require "bio/db/nexml/mapper"

#Autoload definition
module Bio
  module NeXML

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
    mautoload %w|State Char States Cell Sequence Matrix|,  'bio/db/nexml/matrix.rb'

    autoload :Parser, 'bio/db/nexml/parser'
    autoload :Writer, 'bio/db/nexml/writer'

    class Nexml
      include Mapper
      include Enumerable
      attr_accessor :version
      attr_accessor :generator

      has_n :otus,  :singularize => false
      has_n :trees, :singularize => false
      has_n :matrices
      
      def initialize( version, generator = 'bioruby' )
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
          add_matrix element
        end
      end
    end #end class Nexml
  end
end

