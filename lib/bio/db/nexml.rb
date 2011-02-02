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
    mautoload %w|State Char States Cell Sequence Format Characters|,  'bio/db/nexml/matrix.rb'

    autoload :Parser, 'bio/db/nexml/parser'
    autoload :Writer, 'bio/db/nexml/writer'
    
    class NexmlWritable < Writer

      # Add helper functions to XML::Node class.
      XML::Node.class_eval do
  
        # Assign namespaces to <tt>self</tt>.
        # ---
        # *Arguments*:
        # * namespaces - a hash of prefix, uri pairs. It delegates the actual addition
        # to the <tt>namespace=</tt> method.
        # >> node = XML::Node.new( 'nexml' )
        # >> node.namespaces = { :nex => "http://www.nexml.org/1.0" }
        # >> node.namespaces = { nil => "http://www.nexml.org/1.0" }
        # >> node
        # => <nexml xmlns:nex="http://www.nexml.org/1.0" xmlns="http://www.nexml.org/1.0"/>
        def namespaces=( namespaces )
          namespaces.each do |prefix, prefix_uri|
            self.namespace = prefix, prefix_uri
          end
        end
  
        # Assign attributes to <tt>self</tt>.
        # ---
        # *Arguments*:
        # * attributes - a hash of name, value pairs. It delegates the actual addition
        # to the <tt>attribute=</tt> method.
        # >> node = XML::Node.new( 'nexml' )
        # >> node.attributes = { :version => '0.9' }
        # >> node
        # => <nexml version="0.9"/>
        def attributes=( attributes )
          attributes.each do |name, value|
            self.attribute = name, value
          end
        end
  
        # Assign a single attribte to <tt>self</tt>.
        # ---
        # *Arguments*:
        # * pair - an array whose first value is the attribute's name and
        # the second value is the attribute's value.
        # >> node = XML::Node.new( 'nexml' )
        # >> node.attribute = 'version', '0.9'
        # >> node
        # => <nexml version="0.9"/>
        def attribute=( pair )
          XML::Attr.new( self, pair.first.to_s, pair.last )
        end
  
        # Assing a single namespace to <tt>self</tt>.
        # ---
        # *Arguments*:
        # * pair - an array whose first value is the namespace prefix and
        # the second value is the namespace uri. Use <tt>nil</tt> as a prefix
        # to create a default namespace.
        # >> node = XML::Node.new( 'nexml' )
        # >> node.namespace = 'nex', "http://www.nexml.org/1.0"
        # >> node.namespace = nil, 'http://www.nexml.org/1.0'
        # >> node
        # => <nexml xmlns:nex="http://www.nexml.org/1.0" xmlns="http://www.nexml.org/1.0"/>
        def namespace=( pair )
          # have to check for a nil prefix
          prefix = ( p = pair.first ) ? p.to_s : p
          XML::Namespace.new( self, prefix, pair.last )
        end
  
      end
    end

    class Nexml
      include Mapper
      include Enumerable
      attr_accessor :version
      attr_accessor :generator

      has_n :otus,       :singularize => false
      has_n :trees,      :singularize => false
      has_n :characters, :singularize => false
      
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
          add_characters element
        end
      end
    end #end class Nexml
  end
end

