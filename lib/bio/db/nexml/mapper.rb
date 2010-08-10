require 'bio/db/nexml/mapper/inflection'
require 'bio/db/nexml/mapper/repository'
require 'bio/db/nexml/mapper/framework'

module Bio
  module NeXML

    # Mapper provides a very small DSL for defining NeXML classes, specifically one-to-many relation
    # between classes as they are found a lot in NeXML. Though the style has been borrowed from
    # ActiveRecord, it should not be mistaken for an ORM. It just factors out repetitive chunk of
    # code that would otherwise be present.
    # 
    # Including Mapper in a class, creates <tt>has_n</tt>, and <tt>belongs_to</tt> class methods
    # by extending Framework module.  These methods are used to define a one-to-many relation
    # between two classes. Two types of one-to-many relation occurs in NeXML.
    # * parent-child - an element <em>contains</em> other elements. In raw NeXML it would mean
    # nested elements.
    # * association  - an element <em>refers</em> to other elements. In raw NeXML it would mean
    # a source element, referred to by several targets.
    #
    # Their implementation however is same. Defining a relation automatically creates methods to
    # add, delete and query objects.
    # 
    #    class Otu
    #      property   :id
    #      belongs_to :otus
    #    end
    #
    #    class Otus
    #      property :id
    #      has_n    :otus
    #    end
    #
    #    t1 = Otu.new
    #    t1.id = 't1'
    #    t2 = Otu.new
    #    t2.id = 't2'
    #    o1 = Otus.new
    #    o1.id = 'o1'
    #
    #    # add to source
    #    o1.add_otu( t1 )          
    #    o1.otus
    #    => [ t1 ]
    #    t1.otus
    #    => o1
    #
    #    # add to target
    #    t2.otus = o1              
    #    o1.otus
    #    => [ t1, t2 ]
    #    t2.otus
    #    => o1
    #
    #    # query from source
    #    o1.has_otu?( t1 )
    #    => true
    #    o1.get_otu_by_id( 't1' )
    #    => t1
    #
    #    # delete from source
    #    o1.delete_otu( t1 )
    #    o1.otus
    #    => [ t2 ]
    #    t1.otus
    #    => nil
    module Mapper # :nodoc: all

      # Gets or sets properties of the receiver.
      def properties( args = {} )
        @properties ||= {}

        # set properties if defined
        args.each do |property, value|
          raise "#{property} not defined" unless respond_to?( setter = "#{property}=" )
          send( setter, value )
        end unless args.empty?

        # return a copy of @properties so that it is not modified inadvertently by the user
        @properties.dup
      end
      alias properties= properties

      def propogator
        self.class.name.key
      end

      private

      def ivar( var )
        instance_variable_get( var ) ||
          instance_variable_set( var, Repository.new )
      end

      def self.included( klass )
        klass.extend Framework
      end
    end #end module Mapper
  end #end module NeXML
end #end module Bio
