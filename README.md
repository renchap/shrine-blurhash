[![Gem Version](https://badge.fury.io/rb/shrine-blurhash.svg)](https://badge.fury.io/rb/shrine-blurhash)

# Shrine::Blurhash

Provides [Blurhash] computing for [Shrine].

## Installation

Add the gem to your `Gemfile`:

```ruby
gem "shrine-blurhash"
```

Then you can load the plugin in your uploader

```ruby
class PictureUploader < Shrine
  plugin :blurhash
end
```

Your attachments will now have a `blurhash` metadata, with a `.blurhash` method for quick access.

## Contributing

### Running tests

After setting up your bucket, run the tests:

```sh
$ bundle exec rake test
```

## License

[MIT](http://opensource.org/licenses/MIT)

[Shrine]: https://github.com/shrinerb/shrine
[Blurhash]: https://blurha.sh
