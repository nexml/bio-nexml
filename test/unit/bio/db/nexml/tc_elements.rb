module Bio
  module NeXML

    class TestNexml < Test::Unit::TestCase

      def setup
        @nexml = Bio::NeXML::Nexml.new 0.9
      end

      def teardown
        @nexml = nil
      end

      def test_is_enumerable
        @nexml.class.ancestors.include? Enumerable
      end

      def test_otus_set
        assert_instance_of Hash, @nexml.otus_set
      end

      def test_trees_set
        assert_instance_of Hash, @nexml.trees_set
      end

      def test_otus
        assert_instance_of Array, @nexml.otus
      end

      def test_trees
        assert_instance_of Array, @nexml.trees
      end

      def test_add_otus
        assert_send [@nexml.otus_set, :empty?]

        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        not_empty = !@nexml.otus_set.empty?
        assert not_empty
      end

      def test_add_trees
        assert_send [@nexml.trees_set, :empty?]

        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees
        
        not_empty = !@nexml.trees_set.empty?
        assert not_empty
      end

      def test_append
        assert_send [@nexml.trees_set, :empty?]

        trees = Bio::NeXML::Trees.new 'trees'
        @nexml << trees
        
        not_empty = !@nexml.trees_set.empty?
        assert not_empty
      end

      def test_each_otus
        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        @nexml.each do |o|
          assert_not_nil o.id
        end
      end

      def test_each_trees
        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees

        @nexml.each do |t|
          assert_not_nil t.id
        end
      end

      def test_each
      end

      def test_get_otus_by_id
        otus = Bio::NeXML::Otus.new 'otus'
        @nexml.add_otus otus

        assert @nexml.get_otus_by_id 'otus'
      end

      def test_get_otu_by_id
      end

      def test_get_trees_by_id
        trees = Bio::NeXML::Trees.new 'trees'
        @nexml.add_trees trees

        assert @nexml.get_trees_by_id 'trees'
      end

      def test_get_tree_by_id
      end

    end #end class TestNexml

    class TestIDTagged < Test::Unit::TestCase

      class IDTagged
        include Bio::NeXML::IDTagged
      end

      def setup
        @idtagged = IDTagged.new
      end

      def test_id
        assert_nil( @idtagged.id )
      end

      def test_id=
        @idtagged.id = "id"
        assert_equal "id", @idtagged.id
      end

    end

    class TestLabelled < Test::Unit::TestCase
      class Labelled
        include Bio::NeXML::Labelled
      end

      def setup
        @labelled = Labelled.new
      end

      def test_label
        assert_nil @labelled.label
      end

      def test_label=
        @labelled.label = "Test Label"
        assert_equal "Test Label", @labelled.label
      end
    end

    class TestOtu < Test::Unit::TestCase

      def setup
        @otu = Bio::NeXML::Otu.new 'otu1'
      end

      def teardown
        @otu = nil
      end

      def test_is_idtagged
        @otu.class.ancestors.include? Bio::NeXML::IDTagged
      end

      def test_is_labelled
        @otu.class.ancestors.include? Bio::NeXML::Labelled
      end

    end #end class TestOtu

    class TestOtus < Test::Unit::TestCase

      def setup
        @otus = Bio::NeXML::Otus.new "otus1"
      end

      def teardown
        @otus = nil
      end

      def test_is_idtagged
        @otus.class.ancestors.include? Bio::NeXML::IDTagged
      end

      def test_is_labelled
        @otus.class.ancestors.include? Bio::NeXML::Labelled
      end

      def test_is_enumerable
        @otus.class.ancestors.include? Enumerable
      end

      def test_otu_set
        assert_instance_of Hash, @otus.otu_set
      end

      def test_otus
        assert_instance_of Array, @otus.otus
      end

      def test_add_otu
        assert_send [@otus.otu_set, :empty?]
        assert_send [@otus.otus, :empty?]

        otu = Bio::NeXML::Otu.new 'otu2'
        @otus << otu

        not_empty = !@otus.otu_set.empty?
        assert not_empty

        not_empty = !@otus.otus.empty?
        assert not_empty
      end

      def test_has_otu?
        otu = Bio::NeXML::Otu.new 'otu3'
        @otus << otu

        assert @otus.has_otu? 'otu3'
      end

      def test_hash_notation
        otu = Bio::NeXML::Otu.new 'otu4'
        @otus << otu

        assert @otus[ 'otu4' ]
      end

      def test_each
        otu5 = Bio::NeXML::Otu.new 'otu5'
        @otus << otu5

        otu6 = Bio::NeXML::Otu.new 'otu6'
        @otus << otu6

        @otus.each do |o|
          assert_not_nil o.id
        end
      end

    end #end class TestOtus

  end
end
