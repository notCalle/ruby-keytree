[![Gem Version](https://badge.fury.io/rb/key_tree.svg)](https://badge.fury.io/rb/key_tree)
[![Maintainability](https://api.codeclimate.com/v1/badges/ac48756e80007e0cd6f9/maintainability)](https://codeclimate.com/github/notCalle/ruby-keytree/maintainability)
[![codecov](https://codecov.io/gh/notCalle/ruby-keytree/branch/master/graph/badge.svg)](https://codecov.io/gh/notCalle/ruby-keytree)
[![Ruby](https://github.com/notCalle/ruby-keytree/actions/workflows/ruby.yml/badge.svg)](https://github.com/notCalle/ruby-keytree/actions/workflows/ruby.yml)

# KeyTree

KeyTree manages trees of hashes, and (possibly nested) forests of such trees,
allowing access to values by key path.

See the [changelog](CHANGELOG.md) for recent changes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'key_tree'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install key_tree

## Usage

```ruby
kt=KeyTree::Tree[a: { b: 1 }]
kt['a.b']
=> 1
kf=KeyTree::Forest[kt, {b: { c: 2 }}]
kt['a.b']
=> 1
kf['b.c']
=> 2
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/notCalle/key_tree. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the KeyTree project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/notCalle/key_tree/blob/master/CODE_OF_CONDUCT.md).
