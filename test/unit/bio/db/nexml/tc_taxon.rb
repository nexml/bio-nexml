module Bio
  module NeXML
    class TestOtu < Test::Unit::TestCase
      def setup
        @otu = Bio::NeXML::Otu.new( 'taxon1', 'A label for taxon1' )
      end

      def test_id
        assert_equal( 'taxon1', @otu.id )
      end

      def test_label
        assert_equal( 'A label for taxon1', @otu.label )
      end

      def test_id=
        @otu.id = 'taxon2'
        assert_equal( 'taxon2', @otu.id )
      end

      def test_label=
        @otu.label = 'New label for taxon1' 
        assert_equal( 'New label for taxon1', @otu.label )
      end
    end

    class TestOtus < Test::Unit::TestCase
      def setup
        @otu1 = Bio::NeXML::Otu.new( 'taxon1', 'A label for taxon1' )
        @otu2 = Bio::NeXML::Otu.new( 'taxon2', 'A label for taxon2' )
        @otu3 = Bio::NeXML::Otu.new( 'taxon3', 'A label for taxon3' )
        @otus = Bio::NeXML::Otus.new( 'taxa1', 'A label for taxa1' )
        @otus << @otu1 << @otu2
      end

      def test_id
        assert_equal( 'taxa1', @otus.id )
      end

      def test_label
        assert_equal( 'A label for taxa1', @otus.label )
      end

      def test_id=
        @otus.id = 'taxa2'
        assert_equal( 'taxa2', @otus.id )
      end

      def test_label=
        @otus.label = 'New label for taxa1' 
        assert_equal( 'New label for taxa1', @otus.label )
      end

      def test_hash_notation
        assert_equal( @otu1, @otus[ 'taxon1' ] )
      end

      def test_append_operator
        assert !@otus.include?( @otu3 )
        rvalue = @otus << @otu3

        # it should append otu to self
        assert @otus.include?( @otu3 )

        # it should return self, so that appends can be chained
        assert_instance_of Otus, rvalue
      end

      def test_delete
        rvalue = @otus.delete( @otu2 )

        # it should delete @otu2
        assert !@otus.include?( @otu2 )

        # it should return the deleted object
        assert_equal @otu2, rvalue
      end

      def test_otus
        [ @otu1, @otu2 ].each do |otu|
          @otus.otus.include?( otu )
        end
      end

      def test_otus=
        assert !@otus.include?( @otu3 )
        @otus.otus = [ @otu3 ]
        assert @otus.include?( @otu3 )
      end

      def test_each
        otus = [ @otu1, @otu2 ]
        @otus.each do |otu|
          assert otus.include?( otu )
        end
      end

      def test_each_with_id
        otus = [ @otu1, @otu2 ]
        @otus.each_with_id do |id, otu|
          assert otus.include?( otu )
          assert otus.include?( @otus[ id ] )
        end
      end

      def test_length
        assert_equal 2, @otus.length
      end

      def test_include
        # it should respond for an otu object
        assert @otus.include?( @otu1 )

        # it should respond for an otu id
        assert @otus.include?( "taxon1" )
        assert @otus.include?( @otu1.id )

        assert !@otus.include?( @otu3 )
      end
    end
  end
end
