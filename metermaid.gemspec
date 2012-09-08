# -*- encoding: utf-8 -*-
require File.expand_path('../lib/metermaid/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Wil Gieseler"]
  gem.email         = ["supapuerco@gmail.com"]
  gem.description   = "Gently pilfers your power usage data from your power company."
  gem.summary       = "Gently pilfers your power usage data from your power company."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "metermaid"
  gem.require_paths = ["lib"]
  gem.version       = Metermaid::VERSION

  gem.add_dependency 'mechanize'
  gem.add_dependency 'rubyzip'
  gem.add_dependency 'thor'
  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'rspec'

end
