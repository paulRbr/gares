$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'gares/version'

Gem::Specification.new do |s|
  s.name        = 'gares'
  s.licenses    = ['MIT']
  s.version     = Gares::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Paul Bonaud']
  s.email       = ['paul+gh@bonaud.fr']
  s.homepage    = 'http://github.com/paulrbr/gares'
  s.summary     = %q(Easily access the publicly available information on gares-en-mouvement.com.)
  s.description = %q(Easily use Ruby or the command line to find information on gares-en-mouvement.com.)

  s.rubyforge_project = 'gares'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'nokogiri', '~> 1.6'
  s.add_dependency 'hashie', '~> 3.4'
  s.add_dependency 'smarter_csv', '~> 1.0'
  s.add_dependency 'unidecoder', '~> 1.1'
  s.add_dependency 'httparty', '~> 0.13'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'gokdok'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'coveralls'

end
