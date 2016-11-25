# ActiveArchiver

Provide export / import to ActiveRecord and support CarrierWave.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_archiver', github:'zaru/active_archiver'
```

And then execute:

    $ bundle

## Usage

```
export = Hoge.find(1).export

Hoge.import(export)

Hoge.find(1).archive
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zaru/active_archiver.

