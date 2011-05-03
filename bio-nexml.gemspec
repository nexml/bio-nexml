Gem::Specification.new do |s|
  # meta
  s.name        = 'bio-nexml'
  s.version     = '0.0.1'
  s.authors     = ['Rutger Vos', 'Anurag Priyam']
  s.email       = ['rutgeraldo@gmail.com', 'anurag08priyam@gmail.com']
  s.homepage    = 'http://rvosa.github.com/bio-nexml/'
  s.license     = 'MIT'

  s.summary     = %q{BioRuby plugin for reading and writing NeXML (http://nexml.org)}
  s.description = %q{This plugin reads, writes and generates NeXML}

  # dependencies
  s.add_dependency('bio', '>= 1.4.1')
  s.add_dependency('libxml-ruby', '>= 1.1.4')

  # gem
  s.files         = Dir['lib/**/*'] + ['LICENSE.txt', 'README.rdoc']
  s.test_file     = "test/test_bio-nexml.rb"
  s.require_paths = ["lib"]
end

