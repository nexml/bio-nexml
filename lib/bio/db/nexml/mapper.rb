module Bio
  module NeXML

    # Mapper provides a very small DSL for defining NeXML classes. Though the style has been borrowed
    # from ActiveRecord, it should not be mistaken for an ORM. It just factors out repetitive chunk of
    # code that would otherwise be present.
    # 
    # Including Mapper in a class, creates <tt>property</tt>, <tt>has_n</tt>, and <tt>belongs_to</tt>
    # class methods by extending Framework module.
    #
    # === Property
    # The <tt>property</tt> method is used to define a property on the class. Creating a property
    # automatically defines getters and setters for it.
    #
    # === One-to-Many
    # <tt>has_n</tt> and <tt>belongs_to</tt> methods are used to define a one-to-many relation
    # between two classes. Two types of one-to-many relation occurs in NeXML.
    #
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
    #      has_n    :otu
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
    #    o1.otu
    #    => [ t1 ]
    #    t1.otus
    #    => o1
    #
    #    # add to target
    #    t2.otus = o1              
    #    o1.otu
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
    #    o1.otu
    #    => [ t2 ]
    #    t1.otus
    #    => nil
    module Mapper

      # Framework is the real workhorse of Mapper.
      # === Properties
      # Properties are nothing but Ruby attributes, accessor methods wrapped over an instance variable.
      # === One-to-Many
      # Simply put, relations are methods wrapped over instance variables or/and hash stores.
      # A source defines, for every target set an instance variable that refers to a hash store( id,
      # object ) of the target objects. To manipulate and query the store, following methods are
      # defined on the source object :
      # * <tt>target</tt> - returns an Array of target objects.
      # * <tt>target=</tt> - set an Array of objects as target.
      # * <tt>add_target</tt>       - add a target.
      # * <tt>delete_target</tt>    - delete a target.
      # * <tt>get_target_by_id</tt> - return a target object with the given id
      # * <tt>has_target</tt>       - determine whether the target object belongs to the source or not.
      # A target defines, for every source an instance variable that refers to the source. Following
      # methods are defined for a target :
      # * <tt>source</tt>  - return the source object to which the target belongs.
      # * <tt>source=</tt> - add the target to a source.
      # Relations are little intricate as the effect of addition or deletion needs to propogate to
      # the other end. Each sides use the knowledge of the storage model of the other side to do so.
      module Framework

        # Define a property on the class.
        #    property :id
        def property( property )
          attr_accessor property
        end

        # Define a source for the target.
        def belongs_to( element )
          attr_reader element
          define_method( "#{element}=" ) do |object,|
            # set
            instance_variable_set( "@#{element}", object )
            # propogate
            object.instance_variable_get( "@#{propogator}" )[ self.id ] = self
          end
        end

        # Define target set for the source.
        #    has_n :otu
        def has_n( element )
          define_method( element ) do
            elements = ivar( "@#{element}" )
            elements.values
          end

          define_method( "#{element}=" ) do |object,|
            elements = {}
            object.each do |o|
              elements[ o.id ] = o
              o.instance_variable_set( "@#{propogator}", self )
            end
            instance_variable_set( "@#{element}", elements )
          end

          define_method( "add_#{element}" ) do |object,|
            elements = ivar( "@#{element}" )
            elements[ object.id ] = object
            object.instance_variable_set( "@#{propogator}", self )
            self
          end

          define_method( "delete_#{element}" ) do |object,|
            elements = ivar( "@#{element}" )
            if deleted = elements.delete( object.id )
              object.instance_variable_set( "@#{propogator}", nil )
            end
            deleted
          end

          define_method( "get_#{element}_by_id" ) do |id,|
            elements = ivar( "@#{element}" )
            elements[ id ]
          end

          define_method( "has_#{element}?" ) do |object,|
            elements = ivar( "@#{element}" )
            object.is_a?( String ) ? elements.has_key?( object ) : elements[ object.id ] == object
          end
        end
      end #end module Framework

      # instance methods

      # Gets or sets properties of the receiver.
      def properties( args = {} )
        @properties ||= {}

        # set properties if defined
        args.each do |property, value|
          raise 'property not defined' unless respond_to?( setter = "#{property}=" )
          send( setter, value )
        end unless args.empty?

        # return a copy of @properties so that it is not modified inadvertently by the user
        @properties.dup
      end
      alias properties= properties

      def key
        name = self.class.to_s
        if i = name.rindex( ':' )
          name = name[ i + 1 .. -1 ]
        end
        name.downcase.to_sym
      end
      alias propogator key

      private

      def ivar( var )
        instance_variable_get( var ) ||
          instance_variable_set( var, {} )
      end

      def self.included( klass )
        klass.extend Framework
      end
    end #end module Mapper
  end #end module NeXML
end #end module Bio
