# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_archiver/version'

Gem::Specification.new do |spec|
  spec.name          = "active_archiver"
  spec.version       = ActiveArchiver::VERSION
  spec.authors       = ["zaru"]
  spec.email         = ["zarutofu@gmail.com"]

  spec.summary       = %q{Provide export / import to ActiveRecord}
  spec.description   = %q{Provide export / import to ActiveRecord}
  spec.homepage      = "https://github.com/zaru/active_archiver"

  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4"
  spec.add_dependency "activesupport", ">= 4"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
