module Bio
  module NeXML
    module Mapper # :nodoc:

      # Repository is a hash based store for NeXML objects.
      class Repository < Hash

        # Append a method to the Repository.
        def <<( object )
          self[ object.id ] = object
          self
        end

        # Reset the object in the repository to use the ones passed.
        def objects=( objects )
          self.clear
          objects.each { |o| self << o }
        end

        alias __delete__ delete

        # Delete an object.
        def delete( object )
          __delete__( object.id )
        end

        alias __each__ each

        # Iterate over each object in the repository.
        def each( &block )
          each_value( &block )
        end

        # Iterate over each object passing both the id and the
        # object to the block given.
        def each_with_id( &block )
          __each__( &block )
        end

        def has?( object )
          self[ object.id ] == object
        end
      end
    end
  end
end
