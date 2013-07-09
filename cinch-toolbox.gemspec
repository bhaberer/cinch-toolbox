# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cinch/toolbox/version'

Gem::Specification.new do |gem|
  gem.name          = "cinch-toolbox"
  gem.version       = Cinch::Toolbox::VERSION
  gem.authors       = ["Brian Haberer"]
  gem.email         = ["bhaberer@gmail.com"]
  gem.description   = %q{A gem of various methods used in many of my plugins. If you need the namespace, let me know.}
  gem.summary       = %q{Common methods used in Cinch Plugins.}
  gem.homepage      = "https://github.com/bhaberer/cinch-toolbox"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency  'rake'
  gem.add_development_dependency  'rspec'
  gem.add_development_dependency  'coveralls'
  gem.add_development_dependency  'fakeweb',    '~> 1.3'
  gem.add_development_dependency  'cinch-test'

  gem.add_dependency              'nokogiri',   '~> 1.6.0'
  gem.add_dependency              'patron',     '~> 0.4.18'
end
