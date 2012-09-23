# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sshwrap/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Jason Heiss']
  gem.email         = ['jheiss@aput.net']
  gem.description   = File.read('README.md')
  gem.summary       = 'Perform batch SSH operations, handling sudo prompts'
  gem.homepage      = 'https://github.com/jheiss/sshwrap'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'sshwrap'
  gem.require_paths = ['lib']
  gem.version       = SSHwrap::VERSION
  gem.add_dependency('net-ssh')
  gem.add_dependency('highline')
end
