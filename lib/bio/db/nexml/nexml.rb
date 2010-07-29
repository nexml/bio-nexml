#load XML library for parser and serializer
require 'xml'

#load required class and module definitions
require "base"

#Autoload definition
module Bio
  module NeXML
    autoload :Otu,    'bio/db/nexml/taxa.rb'
    autoload :Otus,   'bio/db/nexml/taxa.rb'
    autoload :Parser, 'bio/db/nexml/parser'
    autoload :Writer, 'bio/db/nexml/writer'

    class Nexml
      include Annotated
      include Enumerable
      attr_accessor :version, :generator
      
      def initialize( version, generator = nil )
        @version = version
        @generator = generator
      end

      #Append a Otus, Trees, or Characters object to any
      #Nexml object.
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

      #Return a hash of 'otus' objects or an empty hash
      #if no 'otus' object has been created yet.
      def otus_set
        @otus_set ||= {}
      end

      #Return a hash of 'trees' objects or an empty hash
      #if no 'trees' object has been created yet.
      def trees_set
        @trees_set ||= {}
      end

      #Return a hash of 'characters' objects or an empty hash
      #if no 'characters' object has been created yet.
      def characters_set
        @characters_set ||= {}
      end

      #Add an 'otus' object.
      def add_otus( otus )
        otus_set[ otus.id ] = otus
      end
      
      #Add a 'trees' object.
      def add_trees( trees )
        trees_set[ trees.id ] = trees
      end

      #Add a 'characters' object.
      def add_characters( characters )
        characters_set[ characters.id ] = characters
      end

      #Iterate over each 'otus' object.
      def each_otus
        otus_set.each_value do |otus|
          yield otus
        end
      end
      
      #Iterate over each 'trees' object.
      def each_trees
        trees_set.each_value do |trees|
          yield trees
        end
      end

      #Iterate over each 'characters' object.
      def each_characters
        characters_set.each_value do |char|
          yield char
        end
      end

      #Iterate over each 'tree' object.
      def each
        trees_set.each_value do |trees|
          trees.each{ |tree| yield tree }
        end
      end

      #Return an 'otus' object with the given id or nil
      #if the 'otus' is not found.
      def get_otus_by_id( id )
        otus_set[ id ]
      end

      #Return an 'otu' object with the given id or nil
      #if the 'otu' is not found.
      def get_otu_by_id( id )
        otus_set.each_value do |otus|
          return otus[ id ] if otus.has_otu? id
        end
        
        nil
      end

      #Return an 'trees' object with the given id or nil.
      def get_trees_by_id( id )
        trees_set[ id ]
      end

      #Return a 'tree' object with the given id or nil.
      def get_tree_by_id( id )
        trees_set.each_value do |trees|
          return trees[ id ] if trees.has? id
        end

        nil
      end

      #Return an 'characters' object with the given id or nil.
      def get_characters_by_id( id )
        characters_set[ id ]
      end

      #Return an 'states' object with the given id or nil.
      def get_states_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          if format.has_states?( id )
            return format.get_states_by_id( id ) 
          end
        end
        
        nil
      end

      #Return an 'char' object with the given id or nil.
      def get_char_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          return format.get_char_by_id( id ) if format.has_char? id
        end

        nil
      end

      #Return an 'state' object with the given id or nil.
      def get_state_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          format.each_states do |states|
            return states.get_state_by_id( id ) if states.has_state?( id )
          end
        end
        
        nil
      end

      #Return an array of 'otus' objects.
      def otus
        otus_set.values
      end

      #Return an array of 'trees' objects.
      def trees
        trees_set.values
      end

      #Return an array of 'characters' objects.
      def characters
        characters_set.values
      end

    end #end class Nexml
  end
end

