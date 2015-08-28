# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)


Gem::Specification.new do |spec|
  spec.name          = "vagrant-custom-command"
  spec.version       = "0.1.0"
  spec.authors       = ["Marcos"]
  spec.email         = ["mpenate@stratio.com"]
  spec.description   = %q{Awesome custom command to do something not yet implemented}
  spec.summary       = spec.description
  spec.homepage      = "http://stratio.com"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  puts spec.executables
  spec.require_paths = Dir["lib/**/*"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
