# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'key_tree/version'

dev_deps = {
  'bundler' => '~> 2.1',
  'codecov' => '~> 0.1',
  'git-version-bump' => '~> 0.15',
  'pry' => '~> 0.12',
  'rake' => '~> 12.3',
  'rspec' => '~> 3.9',
  'rubocop' => '~> 0.80',
  'ruby-prof' => '~> 1.3',
  'simplecov' => '~> 0.18'
}

Gem::Specification.new do |spec|
  spec.name          = 'key_tree'
  spec.version       = KeyTree::VERSION
  spec.authors       = ['Calle Englund']
  spec.email         = ['calle@discord.bofh.se']

  spec.summary       = 'Manage trees of keys'
  spec.homepage      = 'https://github.com/notcalle/ruby-keytree'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.platform = Gem::Platform::RUBY
  spec.required_ruby_version = '~> 2.3'

  dev_deps.each { |d| spec.add_development_dependency(*d) }
end
