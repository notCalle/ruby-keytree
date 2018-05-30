# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

begin
  require 'git-version-bump'
rescue LoadError
  gem 'git-version-bump', '~> 0.15'
else
  # Specify your gem's dependencies in key_tree.gemspec
  gemspec
end
