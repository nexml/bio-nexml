module Bio
  module NeXML
    module Mapper

      # Framework is the real workhorse of Mapper.
      module Framework

        # Define a source for the target.
        def belongs_to( name )
          # create attribute reader for source
          attr_reader name                                        # def source; @source; end

          # create an attribute setter for source
          define_method( "_#{name}=" ) do |source,|               # def _source=( source )
            instance_variable_set( "@#{name}", source )           #   @source = source
          end                                                     # end

          # assign a target to source
          define_method( "#{name}=" ) do |source,|                # def source=( source )
            send( "_#{name}=", source )                           #   _source = source
            source.send( "_#{propogator}=", self )                #   source._target = self
          end                                                     # end
        end

        # Define target set for the source.
        #    has_n :otu
        def has_n( name, options = {} )
          name_p = name.to_s
          name_s = ( options[ :singularize ] == false ) ? name_p : name_p.singular

          define_method( "_#{name_s}=" ) do |object,|             # def _target=( source )
            ivar( "@#{name_p}" ) << object                        #   @targets << source
          end                                                     # end       

          define_method( "add_#{name_s}" ) do |object,|           # def add_target( target )
            send( "_#{name_s}=", object )                         #   @targets << target 
            object.send( "_#{propogator}=", self )                #   target.set_source( self )
            self                                                  # end
          end

          define_method( "delete_#{name_s}" ) do |object,|        # def delete_target( source )
            if deleted = ivar( "@#{name_p}" ).delete( object )    #   if d = @targets.delete[ source ]
              object.send( "_#{propogator}=", nil )               #     source.delete( self )
            end                                                   #   end
            deleted                                               #   d
          end                                                     # end

          define_method( name_p ) do                              # def targets
            ivar( "@#{name_p}" ).values                           #   @targets.values
          end                                                     # end

          define_method( "#{name_p}=" ) do |object,|              # def targets=( targets )
            instance_variable_set( "@#{name_p}", Repository.new ) #   @targets = Repository.new
            object.each do |o|                                    #   targets.each do |t|
              send( "add_#{name_s}", o )                          #     add_target( t )
            end                                                   #   end
          end                                                     # end

          define_method( "get_#{name_s}_by_id" ) do |id,|         # def get_target_by_id( id )
            ivar( "@#{name_p}" )[ id ]                            #   @targets[ id ]         
          end                                                     # end

          define_method( "has_#{name_s}?" ) do |object,|          # def has_target?( object )
            elements = ivar( "@#{name_p}" )                       #   object.is_a?( String ) ?
            object.is_a?( String ) ?                              #     @targets.has_key?( object ) :
              elements.has_key?( object ) :                       #       @targets.has?( object )
              elements.has?( object )                             # end
          end

          define_method( "number_of_#{name_p}" ) do
            ivar( "@#{name_p}" ).length
          end

          iterators = <<_END_
          def each_#{name_s}( &block )
            ivar( :@#{name_p} ).each( &block )
          end

          def each_#{name_s}_with_id( &block )
            ivar( :@#{name_p} ).each_with_id( &block )
          end
_END_
          class_eval( iterators )
        end
      end #end module Framework
    end
  end
end
