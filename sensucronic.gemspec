# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sensucronic/version'

Gem::Specification.new do |s|
  s.name          = "sensucronic"
  s.version       = Sensucronic::VERSION
  s.authors       = ["fess"]
  s.email         = ["fess-sensucronic@fess.org"]

  s.summary       = %q{report status of cronjob to sensu}
  #s.description   = %q{}
  #s.homepage      = "TODO: Put your gem's website or public repo URL here."
  s.license       = "MIT"

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  s.bindir        = "exe"
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "mixlib-cli", ">= 1.0" # optimistic

  s.add_development_dependency "bundler", "~> 1.14"
  s.add_development_dependency "rake",    "~> 10.0"
  s.add_development_dependency "rspec",   "~> 3.0"
end
