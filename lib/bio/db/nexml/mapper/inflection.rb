module Bio
  module NeXML
    module Mapper # :nodoc: 

      # String inflections. This module is mixed with the String class.
      #
      #    "targets".singular     #=> "target"
      #    "target".plural        #=> "targets"
      #    "Bio::NeXML::Otu".key  #=> "otu"
      module Inflections
        PLURALS =
          [
            [ /$/, 's' ],
            [ /s$/i, 's' ],
            [ /(ax|test)is$/i, '\1es' ],
            [ /(octop|vir)us$/i, '\1i' ],
            [ /(alias|status)$/i, '\1es' ],
            [ /(bu)s$/i, '\1ses' ],
            [ /(buffal|tomat)o$/i, '\1oes' ],
            [ /([ti])um$/i, '\1a' ],
            [ /sis$/i, 'ses' ],
            [ /(?:([^f])fe|([lr])f)$/i, '\1\2ves' ],
            [ /(hive)$/i, '\1s' ],
            [ /([^aeiouy]|qu)y$/i, '\1ies' ],
            [ /(x|ch|ss|sh)$/i, '\1es' ],
            [ /(matr|vert|ind)(?:ix|ex)$/i, '\1ices' ],
            [ /([m|l])ouse$/i, '\1ice' ],
            [ /^(ox)$/i, '\1en' ],
            [ /(quiz)$/i, '\1zes' ]
        ]

        SINGULARS = 
          [
            [ /s$/i, '' ],
            [ /(n)ews$/i, '\1ews' ],
            [ /([ti])a$/i, '\1um' ],
            [ /((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '\1\2sis' ],
            [ /(^analy)ses$/i, '\1sis' ],
            [ /([^f])ves$/i, '\1fe' ],
            [ /(hive)s$/i, '\1' ],
            [ /(tive)s$/i, '\1' ],
            [ /([lr])ves$/i, '\1f' ],
            [ /([^aeiouy]|qu)ies$/i, '\1y' ],
            [ /(s)eries$/i, '\1eries' ],
            [ /(m)ovies$/i, '\1ovie' ],
            [ /(x|ch|ss|sh)es$/i, '\1' ],
            [ /([m|l])ice$/i, '\1ouse' ],
            [ /(bus)es$/i, '\1' ],
            [ /(o)es$/i, '\1' ],
            [ /(shoe)s$/i, '\1' ],
            [ /(cris|ax|test)es$/i, '\1is' ],
            [ /(octop|vir)i$/i, '\1us' ],
            [ /(alias|status)es$/i, '\1' ],
            [ /^(ox)en/i, '\1' ],
            [ /(vert|ind)ices$/i, '\1ex' ],
            [ /(matr)ices$/i, '\1ix' ],
            [ /(quiz)zes$/i, '\1' ],
            [ /(database)s$/i, '\1' ]
        ]

        # Return the singular form of string.
        def singular
          result = self.dup
          SINGULARS.each do |match, replace|
            rule = Regexp.compile( match )
            unless match( rule ).nil?
              result = gsub( rule, replace) 
            end
          end
          return result
        end

        # Return the plural form of a string.
        def plural
          result = self.dup
          PLURALS.each do |match_exp, replacement_exp|
            unless match(Regexp.compile(match_exp)).nil?
              result =  gsub(Regexp.compile(match_exp), replacement_exp)
            end
          end
          return result
        end

        # For a module name as "Bio::NeXML" return "nexml".
        def key
          result = self.dup
          if i = rindex( ':' )
            result = self[ i + 1 .. -1 ]
          end
          result.downcase
        end
      end # end module Inflections

      String.class_eval do
        include Inflections
      end
    end #end module Mapper
  end #end module NeXML
end #end module Bio
