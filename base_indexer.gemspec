$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'base_indexer/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'base_indexer'
  s.version     = BaseIndexer::VERSION
  s.authors     = ['Ahmed Alsum','Laney McGlohon']
  s.email       = ['laneymcg@stanford.edu']
  s.summary     = 'Summary of BaseIndexer.'
  s.description = 'Description of BaseIndexer.'
  s.license     = 'Apache 2'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  # s.test_files = Dir["test/**/*"]
  # s.test_files = Dir["spec/**/*"]
  s.add_dependency 'rails', '~> 4'
  s.add_dependency 'discovery-indexer', '>= 2', '<= 4.0'
  s.add_dependency 'retries'
  s.add_dependency 'dor-fetcher'

  s.add_development_dependency 'sqlite3'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'vcr'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'yard' # for documentation

  s.add_development_dependency 'engine_cart'
  s.add_development_dependency 'jettywrapper'
end
