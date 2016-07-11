$:.push File.expand_path("../lib", __FILE__)

require "radbear_mobile/version"

Gem::Specification.new do |s|
  s.name        = "radbear_mobile"
  s.version     = RadbearMobile::VERSION
  s.authors     = ["Gary Foster"]
  s.email       = ["gary@radicalbear.com"]
  s.homepage    = "http://www.radicalbear.com"
  s.summary     = "A library of common functions for rad bear iOS and Android mobile apps"
  s.description = "A library of common functions for native iOS and Android mobile apps connected to a Rails back end API, developed by Radical Bear"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rabl", "~> 0.12"
  s.add_dependency "koala", "~> 2.2.0"
  s.add_dependency "rails", "~> 5"

  s.add_development_dependency "rspec-rails", "~> 3"
  s.add_development_dependency "factory_girl_rails", "~> 4"
end
