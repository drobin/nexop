# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nexop/version'

Gem::Specification.new do |spec|
  spec.name          = "nexop"
  spec.version       = Nexop::VERSION
  spec.authors       = ["Robin Doer"]
  spec.email         = ["robin@robind.de"]
  spec.description   = "SSH packet and transport layer implementation"
  spec.summary       = "The Nexop library provides SSH daemon functionality " +
                       "to be able to integrate SSH encryption abilities " +
                       "into existing applications."
  spec.homepage      = "https://github.com/drobin/nexop"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "log4r"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "yard"
end
