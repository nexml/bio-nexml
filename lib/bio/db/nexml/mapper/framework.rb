module Bio
  module NeXML
    module Mapper

      # Framework is the real workhorse of Mapper.
      module Framework

        # Define a source for the target.
        #    belongs_to :source
        def belongs_to( name, options = {} )
          update = ( options[ :update ] || self.name.key ).to_sym

          # create attribute reader for source
          attr_reader name

          # Add this target to a source.
          #    def add_to_source( source )
          #      return if @source == source or source.nil?
          #      @source = source
          #      source.add_target( self )
          #    end
          define_method( "add_to_#{name}" ) do |source,|
            # return if the target already belongs to
            # the given source or if the source is nil.
            return if ivget( name ) == source or source.nil?

            # add source and send a message to source
            # to add self as target.
            ivset( name, source )
            source.send( "add_#{update}", self )
          end

          # Set or remove source.
          #    def source=( source )
          #      return remove_from_source if source.nil?
          #      return add_to_source( self )
          #    end
          define_method( "#{name}=" ) do |source,|
            return send( "remove_from_#{name}" ) if source.nil?
            return send( "add_to_#{name}", source )
          end

          # Remove this target from an existing source.
          #    def remove_from_source
          #      return unless source = @source
          #      @source = nil
          #      source.delete_target( self )
          #    end
          define_method( "remove_from_#{name}" ) do
            # return if a sourc is not set.
            return unless source = ivget( name )

            # remove source and send a message to source
            # to remove itself as target.
            ivset( name, nil )
            source.send( "delete_#{update}", self )
          end
        end

        # Define target set for the source.
           # has_n :otu
        def has_n( target, options = {} )
          name = ( options[ :singularize ] == false ) ? target.to_s : target.to_s.singular
          type = ( options[ :index ] == false ) ? ArrayRepository : HashRepository
          update = ( options[ :update ] || self.name.key ).to_sym

          # Return an Array of targets.
          #    def targets
          #      @targets.objects
          #    end
          define_method( target ) do
            repository( target, type ).objects
          end

          # Set an Array as a target.
          #    def targets=( targets )
          #      @targets.clear
          #      targets.each do |t|
          #        add_target( t )
          #      end
          #    end
          define_method( "#{target}=" ) do |objects,|
            repository( target, type ).clear
            objects.each do |o|                     
              send( "add_#{name}", o )  
            end                        
          end                         

          # Add a target.
          #    def add_target( target )
          #      return if @targets.include?( target )
          #      @targets.append( target )
          #      target.source = self
          #    end
          define_method( "add_#{name}" ) do |object,|
            repository = repository( target, type )
            return if repository.include?( object )
            repository.append( object )
            object.send( "#{update}=", self )
            self
          end

          # Delete a target.
          #    def delete_target( target )
          #      return unless @targets.include?( target )
          #      return unless deleted = @targets.delete( target )
          #      target.source = nil
          #    end
          define_method( "delete_#{name}" ) do |object,|
            repository = repository( target, type )
            return unless deleted = repository.delete( object )
            object.send( "#{update}=", nil )
            deleted
          end                                          

          # Return the number of targets a source has.
          #    def number_of_targets
          #      @targets.length
          #    end
          define_method( "number_of_#{target}" ) do
            repository( target, type ).length
          end

          # Return true if the source has the given target.
          #    def has_target?( target )
          #      @targets.include?( target )
          #    end
          define_method( "has_#{name}?" ) do |object,|
            repository( target, type ).include?( object )
          end

          # Iterate over each target.
          #    def each( &block )
          #      @targets.each( &block )
          #    end
          define_method("each_#{name}") do |&block|
            repository(target, type).each( &block )
          end

          if type == HashRepository
            define_method( "get_#{name}_by_id" ) do |id,|
              repository( target, type )[ id ]          
            end                                        

            define_method("each_#{name}_with_id") do |&block|
              repository(target, type).each_with_id(&block)
            end
          end
        end

      end #end module Framework
    end #end module Mapper
  end #end module NeXML
end #end module Mapper
