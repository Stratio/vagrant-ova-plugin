# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |spec|
  spec.name          = "vagrant-ova-command"
  spec.version       = "0.1.0"
  spec.authors       = ["Marcos Peñate"]
  spec.email         = ["mpenate@stratio.com"]
  spec.description   = %q{Converts from vagrant packaged vbox machines to vmware machines}
  spec.summary       = %q{NA}
  spec.homepage      = "http://stratio.com"
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f)}
  spec.require_paths = ["lib"]  
end