# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'key_tree/version'

dev_deps = {
  'bundler' => '~> 2.0',
  'git-version-bump' => '~> 0.15',
  'pry' => '~> 0.11',
  'rake' => '~> 10.0',
  'rspec' => '~> 3.0',
  'rubocop' => '~> 0.57',
  'ruby-prof' => '~> 0.17',
  'simplecov' => '~> 0.16'
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
