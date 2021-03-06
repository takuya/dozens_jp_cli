# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dozens_jp_cli/version'

Gem::Specification.new do |spec|
  spec.name          = "dozens_jp_cli"
  spec.version       = DozensJpCli::VERSION
  spec.authors       = ["takuya"]
  spec.email         = ["takuya.1st+nospam@gmail.com"]
  spec.summary       = %q{dozens.jp client. }
  spec.description   = %q{dozens.jp client. for update  A recored }
  spec.homepage      = "https://github.com/takuya/dozens_jp_cli"
  spec.license       = "GNUv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "mechanize"
end
