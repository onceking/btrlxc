# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'btrlxc/version'

Gem::Specification.new do |spec|
  spec.name          = "btrlxc"
  spec.version       = Btrlxc::VERSION
  spec.authors       = ["Sai Ke WANG"]
  spec.email         = ["sai@onceking.com"]
  spec.summary       = %q{Manage LXC containers on btrfs.}
  spec.homepage      = "https://github.com/onceking/btrlxc"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-shellout", "~> 2.0"
  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "inifile", "~> 2.0"
  spec.add_dependency "netaddr", "~> 1.5"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
