module Bio
  class NeXML

    module Base
      attr_accessor :xml_base
      attr_accessor :xml_id
      attr_accessor :xml_lang
      attr_accessor :xml_space

    end #end module Base

    module Annotated
      include Base
    end

    module Labelled
      include Annotated
      attr_accessor :label

    end #end module Labelled

    module IDTagged
      include Labelled
      attr_accessor :id

    end #end module IDTagged

    module TaxaLinked
      include IDTagged
      attr_accessor :otus

    end #end module TaxaLinked

    module TaxonLinked
      include IDTagged
      attr_accessor :otu

    end #end module TaxonLinked

  end
end
