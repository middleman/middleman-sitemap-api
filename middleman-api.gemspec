# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-api/version"

Gem::Specification.new do |s|
  s.name        = "middleman-api"
  s.version     = Middleman::API::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["me@tdreyno.com"]
  s.homepage    = "https://github.com/middleman/middleman-api"
  s.summary     = %q{Middleman Resource API}
  s.description = %q{Middleman Resource API}

  s.rubyforge_project = "middleman-api"
  s.required_ruby_version = ">= 1.9.3"

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]
  
  s.add_dependency("middleman-core", ["~> 3.2.0"])
  s.add_dependency("grape", ["~> 0.6.1"])
end
