module Bio
  module NeXML

    class TestNexml < Test::Unit::TestCase

      def setup
        @doc = Parser.new( TEST_FILE, true )
        @nexml = @doc.parse
      end

      def teardown
        @nexml = nil
        @doc.close
      end

      def test_for_otus_presence
        not_empty = !@nexml.otus.empty?
        assert not_empty, "Should return an array of atleast one otus object."
      end

      def test_for_otus_type
        otus_set = @nexml.otus
        otus_set.each do |otus|
          assert_instance_of Bio::NeXML::Otus, otus
        end
      end

      def test_for_trees
        assert_respond_to @nexml, :trees, "Should return an array of trees object."
      end

      def test_for_trees_type
        trees_set = @nexml.trees
        trees_set.each do |trees|
          assert_instance_of Bio::NeXML::Trees, trees
        end
      end

    end #end class TestNexml

    class TestOtus < Test::Unit::TestCase

      def setup
        @doc = Parser.new( TEST_FILE, true )
        @otus = @doc.parse.otus.first
      end

      def teardown
        @otus = nil
        @doc.close
      end

      def test_otus_for_id
        assert_not_nil @otus.id, "An otus object should have an id."
      end

      def test_otus_for_label
        assert_respond_to @otus, :label, "An otus can have a label."
      end

      def test_for_otu
        assert_respond_to @otus, :otu, "Should return an array of otu object."
      end

      def test_for_otu_type
        otu_set = @otus.otu
        otu_set.each do |otu|
          assert_instance_of Bio::NeXML::Otu, otu
        end
      end

    end #end class TestOtus

    class TestOtu < Test::Unit::TestCase

      def setup
        @doc = Parser.new( TEST_FILE, true )
        @otu = @doc.parse.otus.first.otu.first
      end

      def teardown
        @otu = nil
        @doc.close
      end

      def test_otu_for_id
        assert_not_nil @otu.id, "An otu object should have an id."
      end

      def test_otu_for_label
        assert_respond_to @otu, :label, "An otu can have a label."
      end

    end #end class TestOtu

  end
end
