#load XML library for parser and serializer
require 'xml'

#load required class and module definitions
require "bio/tree"
require 'bio/db/nexml/elements'

#Autoload definition
module Bio
  module NeXML
    autoload :Parser, 'bio/db/nexml/parser'
  end
end

