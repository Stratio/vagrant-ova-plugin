# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-ova/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-ova"
  spec.version       = VagrantPlugins::VagrantOva::VERSION
  spec.authors       = ["Marcos Peñate"]
  spec.email         = ["mpenate@stratio.com"]
  spec.description   = %q{Vagrant .box to .ova converter}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/Stratio/vagrant-ova-plugin"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
