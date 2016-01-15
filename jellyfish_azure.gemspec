$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'jellyfish_azure/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'jellyfish-azure'
  s.version     = JellyfishAzure::VERSION
  s.authors     = ['']
  s.email       = ['']
  s.homepage    = 'http://github.com/projectjellyfish/jellyfish-azure'
  s.summary     = 'Adds Azure products to Jellyfish'
  s.description = 'Adds Azure ... to Jellyfish'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.test_files = Dir['spec/**/*']
  s.add_dependency 'rails', '~> 4.2'
  s.add_dependency 'bcrypt', '~> 3.1'
  s.add_dependency 'waitutil', '~> 0.2.1'
  s.add_dependency 'azure', '~> 0.7.1'
  s.add_dependency 'azure_mgmt_storage', '~> 0.1.1'
  s.add_dependency 'azure_mgmt_resources', '~> 0.1.1'

  s.add_development_dependency 'rspec-rails', '~> 3.3'
  s.add_development_dependency 'factory_girl_rails', '~> 4.5'
  s.add_development_dependency 'rubocop', '~> 0.34'
  s.add_development_dependency 'simplecov', '~> 0.10.0'
end
