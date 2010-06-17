module Bio
  module NeXML

    #exception classes
    class InvalidRowException < Exception; end
    class InvalidMatrixException < Exception; end
    class InvalidCharException < Exception; end
    class InvalidStateException < Exception; end
    class InvalidStatesException < Exception; end
    class InvalidFormatExcetpion < Exception; end
    class InvalidFormatExcetpion < Exception; end

    module Base
      def xml_base
        @xml_base
      end

      def xml_base=( base )
        @xml_base = base
      end

      def xml_id
        @xml_id
      end

      def xml_id=( id )
        @xml_id = id
      end

      def xml_lang
        @xml_lang
      end

      def xml_lang=( lang )
        @xml_lang = lang
      end

      def xml_space
        @xml_space
      end

      def xml_space=( space )
        @xml_space = space
      end

      #xlink:href not done yet

    end #end module Base

    module Annotated
      include Base
    end

    class Nexml
      include Annotated
      include Enumerable
      attr_accessor :version, :generator
      
      def initialize( version, generator = nil )
        @version = version
        @generator = generator
      end

      #Append a Otus, Trees, or Characters object to any
      #Nexml object.
      def <<( element )
        case element
        when Otus
          add_otus element
        when Trees
          add_trees element
        when Characters
          add_characters element
        end
      end

      #Return a hash of 'otus' objects or an empty hash
      #if no 'otus' object has been created yet.
      def otus_set
        @otus_set ||= {}
      end

      #Return a hash of 'trees' objects or an empty hash
      #if no 'trees' object has been created yet.
      def trees_set
        @trees_set ||= {}
      end

      #Return a hash of 'characters' objects or an empty hash
      #if no 'characters' object has been created yet.
      def characters_set
        @characters_set ||= {}
      end

      #Add an 'otus' object.
      def add_otus( otus )
        otus_set[ otus.id ] = otus
      end
      
      #Add a 'trees' object.
      def add_trees( trees )
        trees_set[ trees.id ] = trees
      end

      #Add a 'characters' object.
      def add_characters( characters )
        characters_set[ characters.id ] = characters
      end

      #Iterate over each 'otus' object.
      def each_otus
        otus_set.each_value do |otus|
          yield otus
        end
      end
      
      #Iterate over each 'trees' object.
      def each_trees
        trees_set.each_value do |trees|
          yield trees
        end
      end

      #Iterate over each 'characters' object.
      def each_characters
        characters_set.each_value do |char|
          yield char
        end
      end

      #Iterate over each 'tree' object.
      def each
        trees_set.each_value do |trees|
          trees.each{ |tree| yield tree }
        end
      end

      #Return an 'otus' object with the given id or nil
      #if the 'otus' is not found.
      def get_otus_by_id( id )
        otus_set[ id ]
      end

      #Return an 'otu' object with the given id or nil
      #if the 'otu' is not found.
      def get_otu_by_id( id )
        otus_set.each_value do |otus|
          return otus[ id ] if otus.has_otu? id
        end
        
        nil
      end

      #Return an 'trees' object with the given id or nil.
      def get_trees_by_id( id )
        trees_set[ id ]
      end

      #Return a 'tree' object with the given id or nil.
      def get_tree_by_id( id )
        trees_set.each_value do |trees|
          return trees[ id ] if trees.has? id
        end

        nil
      end

      #Return an 'characters' object with the given id or nil.
      def get_characters_by_id( id )
        characters_set[ id ]
      end

      #Return an 'states' object with the given id or nil.
      def get_states_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          if format.has_states?( id )
            return format.get_states_by_id( id ) 
          end
        end
        
        nil
      end

      #Return an 'char' object with the given id or nil.
      def get_char_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          return format.get_char_by_id( id ) if format.has_char? id
        end

        nil
      end

      #Return an 'state' object with the given id or nil.
      def get_state_by_id( id )
        characters_set.each_value do |characters|
          format = characters.format
          format.each_states do |states|
            return states.get_state_by_id( id ) if states.has_state?( id )
          end
        end
        
        nil
      end

      #Return an array of 'otus' objects.
      def otus
        otus_set.values
      end

      #Return an array of 'trees' objects.
      def trees
        trees_set.values
      end

      #Return an array of 'characters' objects.
      def characters
        characters_set.values
      end

    end #end class Nexml

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

    class Otu
      include IDTagged

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

    end #end class Otu

    class Otus
      include IDTagged
      include Enumerable

      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      #Return a hash of 'otu' objects or
      #an empty hash if no 'otu' object created yet.
      def otu_set
        @otu_set ||= {}
      end

      #Return an array of 'otu' objects.
      def otus
        otu_set.values
      end

      #Iterate over all 'otu' object.
      def each
        otu_set.each_value do |otu|
          yield otu
        end
      end
      alias :each_otu :each

      def each_with_id
        otu_set.each do |id, otu|
          yield id, otu
        end
      end

      #Use array notation to access an 'otu'
      def []( key )
        otu_set[ key ]
      end
      alias get_otu_by_id []

      #Checks if this 'otus' contains an 'otu'
      #with the given id.
      def has_otu?( id )
        otu_set.has_key? id
      end
      alias include? has_otu?

      #Add an 'otu' to this 'otus'
      def <<( otu )
        otu_set[ otu.id ] = otu
      end
      alias add_otu <<

    end #end class Otus

    class Node < Bio::Tree::Node
      include TaxonLinked
      attr_writer :root

      def initialize( id, otu = nil, root = false, label = nil )
        #use id for node's name
        super id
        @id = id
        @label = label
        self.otu = otu if otu
        @root = root
      end

      #Assign an otu to a node.
      def otu=( otu )
        @otu = otu
        self.taxonomy_id = otu.id
      end

      #Is it a root node?
      def root?
        @root
      end

    end #end class Node

    class Edge < Bio::Tree::Edge
      include IDTagged
      attr_accessor :source, :target

      def initialize( id, source, target, length = nil, label = nil )
        super length
        @id = id
        @label = label
        @source = source
        @target = target
      end

      def length
        self.distance
      end

      def length=( length )
        self.distance = length
      end

    end #end class Edge

    class IntEdge < Edge

      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_i
        super
      end

    end #end class IntEdge

    class FloatEdge < Edge
      def initialize( id, source, target, length = nil, label = nil )
        length = length.to_f
        super
      end
    end #end class FloatEdge

    class RootEdge < Edge
      def initialize( id, target, length = nil, label = nil )
        super( id, nil, target, length, label )
      end
    end

    class AbstractTree < Bio::Tree
      include IDTagged

      def initialize( id, label = nil )
        super()
        @id = id
        @label = label
      end

      def root
        @root ||= []
      end

      def node_set
        @node_set ||= {}
      end

      def edge_set
        @edge_set ||= {}
      end

      def get_node_by_id( id )
        node_set[ id ]
      end
      alias get_node_by_name get_node_by_id

      def get_edge_by_id( id )
        edge_set[ id ]
      end

      def add_node( node )
        node_set[ node.id ] = node
        super
      end

      def nodes
        node_set.values
      end

      alias extended_edges edges
      def edges
        edge_set.values
      end

      #Add an edge to the tree.
      def add_edge( edge )
        edge_set[ edge.id ] = edge
        source = get_node_by_name( edge.source )
        target = get_node_by_name( edge.target )
        super source, target, edge
      end

    end

    class Tree < AbstractTree
      attr_accessor :rootedge

      def initialize( id, label = nil )
        super
      end

      #Add a rootedge to the tree
      def add_rootedge( edge )
        self.rootedge = edge
      end

      def target_cache
        @target_cache ||= []
      end

      def add_edge( edge )
        target = get_node_by_name( edge.target )
        raise "Target exists." if target_cache.include? target
        target_cache << target
        super
      end

      def parent( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        parents = {}
        root.each do |r|
          parents[ r ] = super( node, r )
        end
        parents
      end

      def children( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        childrens = {}
        root.each do |r|
          c = adjacent_nodes(node)
          c.delete(parent(node, r)[ r ])
          childrens[ r ] = c
        end

        childrens
      end

      def descendents( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        descendent = {}
        root.each do |r|
          descendent[ r ] = super( node, r )
        end
        descendent
      end

      def lowest_common_ancestor( node1, node2, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        lca = {}
        root.each do |r|
          lca[ r ] = super( node1, node2, r )
        end
        lca
      end

      def ancestors( node, *root )
        if root.empty?
          raise IndexError, 'can not get parent for unrooted tree' if self.root.empty?
          root = self.root
        end
        ancestor = {}
        root.each do |r|
          ancestor[ r ] = super( node, r )
        end
        ancestor
      end

    end #end class Tree

    class IntTree < Tree ; end
    class FloatTree < Tree ; end

    class Network < AbstractTree

      def initialize( id, label = nil )
        super
      end

    end

    class IntNetwork < Network; end
    class FloatNetwork < Network; end

    class Trees
      include TaxaLinked
      include Enumerable

      def initialize( id, otus, label = nil )
        @id = id
        @label = label
        @otus = otus
      end

      #Access child tree objects with a hash like notation
      #given its id.
      def []( id )
        tree_set[ id ] or network_set[ id ]
      end

      #Iterate over child elements, i.e. all the
      #'tree' and 'network' object.
      def each
        tree_set.each_value do |tree|
          yield tree
        end
        network_set.each_value do |network|
          yield network
        end
      end

      #Add a 'tree' or a 'network'.
      def <<( element )
        #order of the when clause matters here
        #as a network is a tree too.
        case element
        when Network
          add_network element
        when Tree
          add_tree element
        end
      end
      
      #Returns a hash of 'tree' objects or
      #an empty hash if none exists.
      def tree_set
        @tree_set ||= {}
      end

      #Returns a hash of 'network' objects or
      #an empty hash if none exists.
      def network_set
        @network_set ||= {}
      end

      def add_network( netowrk )
        network_set[ netowrk.id ] = netowrk
      end

      def add_tree( tree )
        tree_set[ tree.id ] = tree
      end

      #Return an array of 'tree' objects.
      def trees
        tree_set.values
      end

      #Return an array of 'network' objects.
      def networks
        network_set.values
      end

      #Iterate over each 'tree' object.
      def each_tree
        tree_set.each_value do |tree|
          yield tree
        end
      end

      #Iterate over each 'network' object.
      def each_network
        network_set.each_value do |network|
          yield network
        end
      end

      #Find if a 'tree' with the given id exists
      #or not.
      def has_tree?( id )
        tree_set.has_key? id
      end

      #Find if a 'network' with the given id exists
      #or not.
      def has_network?( id )
        network_set.has_key? id
      end

      def has?( id )
        has_tree?( id ) or has_network?( id )
      end
      alias include? has?

      def number_of_trees
        tree_set.length
      end

      def number_of_networks
        network_set.length
      end

      def number_of_graphs
        number_of_trees + number_of_networks
      end

      def get_tree_by_id( id )
        tree_set[ id ]
      end

      def get_network_by_id( id )
        network_set[ id ]
      end

    end #end class Trees

    class Characters
      include IDTagged
      include TaxaLinked
      attr_accessor :format, :matrix

      def initialize( id, otus, label = nil )
        @id = id
        @otus = otus
        @label = label
      end

      def <<( element )
        case element
        when Format
          self.format = element
        when Matrix
          self.matrix = element
        end
      end

    end #end class Characters

    class Seqs < Characters

      def initialize( id, otus, label = nil )
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a SeqMatrix type." unless matrix.kind_of? SeqMatrix
        super
      end

    end #end class Seqs

    class Cells < Characters

      def initialize( id, otus, label = nil )
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a CellMatrix type." unless matrix.kind_of? CellMatrix
        super
      end

    end #end class Cells

    class DnaSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a DnaFormat type." unless format.instance_of? DnaFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a DnaSeqMatrix type." unless matrix.instance_of? DnaSeqMatrix
        super
      end

    end #end class DnaSeqs

    class RnaSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a RnaFormat type" unless format.instance_of? RnaFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a RnaSeqMatrix type." unless matrix.instance_of? RnaSeqMatrix
        super
      end

    end #end class RnaSeqs

    class RestrictionSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a RestrictionFormat type" unless format.instance_of? RestrictionFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a RestrictionSeqMatrix type." unless matrix.instance_of? RestrictionSeqMatrix
        super
      end

    end #end class RestrictionSeqs

    class ProteinSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a ProteinFormat type" unless format.instance_of? ProteinFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a ProteinSeqMatrix type." unless matrix.instance_of? ProteinSeqMatrix
        super
      end

    end #end class ProteinSeqs

    class StandardSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a StandardFormat type" unless format.instance_of? StandardFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a StandardSeqMatrix type." unless matrix.instance_of? StandardSeqMatrix
        super
      end

    end #end class StandardSeqs

    class ContinuousSeqs < Seqs

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a ProteinFormat type" unless format.instance_of? ContinuousFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a ContinuousSeqMatrix type." unless matrix.instance_of? ContinuousSeqMatrix
        super
      end

    end #end class ContinuousSeqs

    class DnaCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a DnaFormat type" unless format.instance_of? DnaFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a DnaCellMatrix type." unless matrix.instance_of? DnaCellMatrix
        super
      end

    end #end class DnaCells

    class RnaCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a RnaFormat type." unless format.instance_of? RnaFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a RnaCellMatrix type." unless matrix.instance_of? RnaCellMatrix
        super
      end

    end #end class RnaCells

    class RestrictionCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a RestrictionFormat type" unless format.instance_of? RestrictionFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a RestrictionCellMatrix type." unless matrix.instance_of? RestrictionCellMatrix
        super
      end

    end #end class RestrictionCells

    class ProteinCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a ProteinFormat type" unless format.instance_of? ProteinFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a ProteinCellMatrix type." unless matrix.instance_of? ProteinCellMatrix
        super
      end

    end #end class ProteinCells

    class StandardCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a StandardFormat type" unless format.instance_of? StandardFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a StandardCellMatrix type." unless matrix.instance_of? StandardCellMatrix
        super
      end

    end #end class StandardCells

    class ContinuousCells < Cells

      def initialize( id, otus, label = nil )
        super
      end

      def format=( format )
        raise InvalidFormatExcetpion, "Takes a ProteinFormat type" unless format.instance_of? ContinuousFormat
        super
      end

      def matrix=( matrix )
        raise InvalidMatrixException, "Takes a ContinuousCellMatrix type." unless matrix.instance_of? ContinuousCellMatrix
        super
      end

    end #end class ContinuousCells

    class Format

      def <<( elements )
        test = elements.instance_of?( Array ) ? elements.first : elements
        case test
        when States
          self.states = elements
        when Char
          self.chars = elements
        end
      end

      def states_set
        @states_set ||= {}
      end

      def char_set
        @char_set ||= {}
      end

      def states
        states_set.values
      end

      def chars
        char_set.values
      end

      def states=( states )
        if states.instance_of?( Array )
          states.each do |ss|
            add_states( ss )
          end
        else
          add_states( states )
        end
      end

      def chars=( chars )
        if chars.instance_of? Array
          chars.each do |char|
            add_char( char )
          end
        else
          add_char( chars )
        end
      end

      def add_states( states )
        states_set[ states.id ] = states
      end

      def add_char( char )
        char_set[ char.id ] = char
      end

      def get_states_by_id( id )
        states_set[ id ]
      end

      def get_char_by_id( id )
        char_set[ id ]
      end

      def []( id )
        char_set[ id ] or states_set[ id ]
      end

      def has_states?( id )
        states_set.has_key? id
      end

      def has_char?( id )
        char_set.has_key? id
      end

      def has?( id )
        has_states?( id ) or has_char?( id )
      end
      alias include? has?

      def each_states
        states_set.each_value do |states|
          yield states
        end
      end

      def each_char
        char_set.each_value do |char|
          yield char
        end
      end

    end #end class Format

    class ProteinFormat < Format
      
      def initialize( states = nil, char = nil )
        self << states
        self << char
      end

      def add_states( states )
        raise InvalidStatesException, "ProteinStates expected" unless states.instance_of? ProteinStates
        super
      end

      def add_char( char )
        raise InvalidCharException, "ProteinCharexpected" unless states.instance_of? ProteinChar
        super
      end

    end

    class ContinuousFormat < Format

      def initialize( char = nil )
        self << char
      end

    end

    class DnaFormat < Format

      def initialize( states = nil, char = nil )
        self << states
        self << char
      end

      def add_states( states )
        raise InvalidStatesException, "DnaStates expected" unless states.instance_of? DnaStates
        super
      end

      def add_char( states )
        raise InvalidCharException, "DnaChar expected" unless states.instance_of? DnaChar
        super
      end

    end

    class RnaFormat < Format

      def initialize( states = nil, char = nil )
        self << states
        self << char
      end
      
      def add_states( states )
        raise InvalidStatesException, "RnaStates expected" unless states.instance_of? RnaStates
        super
      end

      def add_char( states )
        raise InvalidCharException, "RnaChar expected" unless states.instance_of? RnaChar
        super
      end

    end

    class RestrictionFormat < Format

      def initialize( states = nil, char = nil )
        self << states
        self << char
      end

      def add_states( states )
        raise InvalidStatesException, "RestrictionStates expected" unless states.instance_of? RestrictionStates
        super
      end

      def add_char( states )
        raise InvalidCharException, "RestrictionChar expected" unless states.instance_of? RestrictionChar
        super
      end

    end

    class StandardFormat < Format

      def initialize( states = nil, char = nil )
        self << states
        self << char
      end

      def add_states( states )
        raise InvalidStatesException, "StandardStates expected" unless states.instance_of? StandardStates
        super
      end

      def add_char( states )
        raise InvalidCharException, "StandardChar expected" unless states.instance_of? StandardChar
        super
      end

    end

    class States
      include IDTagged
      
      def initialize( id, label = nil )
        @id = id
        @label = label
      end

      def state_set
        @state_set ||= {}
      end

      def states
        state_set.values
      end

      def states=( states )
        if states.instance_of? Array
          states.each do |state|
            add_state( state )
          end
        else
          add_state( state )
        end
      end
      alias << states=

      def add_state( state )
        state_set[ state.id ] = state
      end

      def get_state_by_id( id )
        state_set[ id ]
      end

      def has_state?( id )
        state_set.has_key? id
      end
      alias :include? :has_state?

    end

    class ProteinStates < States

      def initialize( id, label = nil )
        super
      end
      
      def add_state( state )
        raise InvalidStateException, "ProteinState expected." unless state.instance_of? ProteinState
        super
      end

    end #end class ProteinStates

    class DnaStates < States

      def initialize( id, label = nil )
        super
      end

      def add_state( state )
        raise InvalidStateException, "DnaState expected." unless state.instance_of? DnaState
        super
      end
      
    end #end class DnaStates

    class RnaStates < States

      def initialize( id, label = nil )
        super
      end
      
      def add_state( state )
        raise InvalidStateException, "RnaState expected." unless state.instance_of? RnaState
        super
      end
      
    end #end class RnaStates

    class RestrictionStates < States

      def initialize( id, label = nil )
        super
      end
      
      def add_state( state )
        raise InvalidStateException, "RestrictionState expected." unless state.instance_of? RestrictionState
        super
      end
      
    end #end class RestrictionStates

    class StandardStates < States

      def initialize( id, label = nil )
        super
      end
      
      def add_state( state )
        raise InvalidStateException, "StandardState expected." unless state.instance_of? StandardState
        super
      end
      
    end #end class StandardStates

    class State
      include IDTagged
      attr_accessor :symbol

      def initialize( id, symbol, label = nil )
        @id = id
        @label = label
        self.symbol = symbol
      end

    end

    class ProteinState < State

      def initialize( id, symbol, label = nil )
        super
      end

    end

    class DnaState < State

      def initialize( id, symbol, label = nil )
        super
      end

    end

    class RnaState < State

      def initialize( id, symbol, label = nil )
        super
      end

    end

    class RestrictionState < State

      def initialize( id, symbol, label = nil )
        super
      end

    end

    class StandardState < State

      def initialize( id, symbol, label = nil )
        super
      end

    end

    class Char
      include IDTagged
      attr_accessor :states
      
      def initialize( id, label = nil )
        @id = id
        self.states = states
        @label = label 
      end

    end

    class ProteinChar < Char

      def initialize( id, label = nil )
        super
      end

    end

    class DnaChar < Char

      def initialize( id, label = nil )
        super
      end

    end

    class RnaChar < Char

      def initialize( id, label = nil )
        super
      end

    end
    
    class RestrictionChar < Char

      def initialize( id, label = nil )
        super
      end

    end

    class ContinuousChar < Char

      def initialize( id, label = nil )
        super
      end

    end

    class StandardChar < Char

      def initialize( id, label = nil )
        super
      end

    end

    class Matrix

      def row_set
        @row_set ||= {}
      end

      def rows
        row_set.values
      end

      def rows=( rows )
        if rows.instance_of? Array
          rows.each do |row|
            add_row( row )
          end
        else
          add_row( rows )
        end
      end
      alias << rows=

      def add_row( row )
        row_set[ row.id ] = row
      end

    end

    class SeqMatrix < Matrix

      def add_row( row )
        raise InvalidRowException, "SeqRow expected." unless row.kind_of? SeqRow
        super
      end

    end

    class ProteinSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "ProteinSeqRow expected." unless row.instance_of? ProteinSeqRow
        super
      end

    end
  
    class ContinuousSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "ContinuousSeqRow expected." unless row.instance_of? ContinuousSeqRow
        super
      end

    end

    class DnaSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "DnaSeqRow expected." unless row.instance_of? DnaSeqRow
        super
      end

    end

    class RnaSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "RnaSeqRow expected." unless row.instance_of? RnaSeqRow
        super
      end

    end

    class RestrictionSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "RestrictionSeqRow expected." unless row.instance_of? RestrictionSeqRow
        super
      end

    end

    class StandardSeqMatrix < SeqMatrix

      def add_row( row )
        raise InvalidRowException, "StandardSeqRow expected." unless row.instance_of? StandardSeqRow
        super
      end

    end

    class CellMatrix < Matrix

      def add_row( row )
        raise InvalidRowException, "CellRow expected." unless row.kind_of? CellRow
        super
      end

    end

    class ProteinCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "ProteinCellRow expected." unless row.instance_of? ProteinCellRow
        super
      end

    end
    
    class DnaCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "DnaCellRow expected." unless row.instance_of? DnaCellRow
        super
      end

    end

    class RnaCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "RnaCellRow expected." unless row.instance_of? RnaCellRow
        super
      end

    end

    class StandardCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "StandardCellRow expected." unless row.instance_of? StandardCellRow
        super
      end

    end
    
    class ContinuousCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "ContinuousCellRow expected." unless row.instance_of? ContinuousCellRow
        super
      end

    end

    class RestrictionCellMatrix < CellMatrix

      def add_row( row )
        raise InvalidRowException, "RestrictionCellRow expected." unless row.instance_of? RestrictionCellRow
        super
      end

    end

    class Row
      include IDTagged
      include TaxonLinked

      def initialize( id, otu = nil, label = nil )
        @id = id
        @otu = otu
        @label = label
      end

      def <<( elements )
        test = elements.instance_of?( Array ) ? elements.first : elements
        case test
        when Seq
          self.seq = elements
        when Cell
          self.cells = elements
        end
      end

    end #end class Row

    class SeqRow < Row
      attr_accessor :seq

      def initialize( id, otu = nil, label = nil )
        super
      end

    end #end class SeqRow

    class DnaSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "DnaSeq required." unless seq.instance_of? DnaSeq
        super
      end

    end #class DnaSeqRow

    class RnaSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "RnaSeq required." unless seq.instance_of? RnaSeq
        super
      end

    end

    class ProteinSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "ProteinSeq required." unless seq.instance_of? ProteinSeq
        super
      end

    end #end class ProteinSeqRow

    class StandardSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "StandardSeq required." unless seq.instance_of? StandardSeq
        super
      end

    end #end class StandardSeqRow

    class RestrictionSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "RestrictionSeq required." unless seq.instance_of? RestrictionSeq
        super
      end

    end #end class RestrictionSeqRow

    class ContinuousSeqRow < SeqRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def seq=( seq )
        raise InvalidSeqException, "ContinuousSeq required." unless seq.instance_of? ContinuousSeq
        super
      end

    end #end class ContinuousSeqRow

    class CellRow < Row

      def initialize( id, otu = nil, label = nil )
        super
      end

      def cells
        @cells ||= []
      end

      def cells=( cells )
        if cells.instance_of? Array
          cells.each do |cell|
            add_cell( cell )
          end
        else
          add_cell( cells )
        end
      end

      def add_cell( cell )
        cells << cell
      end

    end #enc class CellRow

    class DnaCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "DnaCell expected" unless cell.instance_of? DnaCell
        super
      end

    end #end class DnaCellRow

    class RnaCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "RnaCell expected" unless cell.instance_of? RnaCell
        super
      end

    end #end class RnaCellRow

    class ProteinCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "ProteinCell expected" unless cell.instance_of? ProteinCell
        super
      end

    end #end class ProteinCellRow

    class ContinuousCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "ContinuousCell expected" unless cell.instance_of? ContinuousCell
        super
      end

    end #end class ContinuousCellRow

    class RestrictionCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "RestrictionCell expected" unless cell.instance_of? RestrictionCell
        super
      end

    end #end class RestrictionCellRow
    
    class StandardCellRow < CellRow

      def initialize( id, otu = nil, label = nil )
        super
      end

      def add_cell( cell )
        raise InvalidCellException, "StandardCell expected" unless cell.instance_of? StandardCell
        super
      end

    end #end class StandardCellRow

    class Seq
      attr_accessor :value
    end

    class DnaSeq < Seq; end
    class RnaSeq < Seq; end
    class StandardSeq < Seq; end
    class RestrictionSeq < Seq; end
    class ContinuousSeq < Seq; end
    class ProteinSeq < Seq; end

    class Cell
      attr_accessor :char, :state
    end

    class DnaCell < Cell; end
    class RnaCell < Cell; end
    class ProteinCell < Cell; end
    class StandardCell < Cell; end
    class RestrictionCell < Cell; end
    class ContinuousCell < Cell; end

  end #end module NeXML

end #end module Bio
