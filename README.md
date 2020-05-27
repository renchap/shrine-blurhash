[![Gem Version](https://badge.fury.io/rb/shrine-blurhash.svg)](https://badge.fury.io/rb/shrine-blurhash)

# Shrine::Blurhash

Provides [Blurhash] computing for [Shrine].

Main features:
- Multiple pixel extractors support. Current implementations:
  - `ruby-vips`
- Resize the image before computing blurhash (to 100 pixels by default) for a faster computation
- Supports custom blurhash components parameter

## Installation

Simply add the gem to your `Gemfile`:

```ruby
gem "shrine-blurhash"
```

Then run `bundler`

## Usage

You first need to load the plugin in your Uploader;

```ruby
class PictureUploader < Shrine
  plugin :blurhash
end
```

Blurhash will be now be computed when you upload a file and stored in a `blurhash` metadata, with a `.blurhash` method for quick access.

## Options

You can pass options to the plugin to customize its behavior.

```ruby
class PictureUploader < Shrine
  plugin :blurhash, resize_to: nil, components: [2, 2]
end
```

### ```components```

Type: `[components_x, components_y]`
Default: `[4, 3]`

```ruby
plugin :blurhash, components: [2, 2]
```

This allows you to customize the number of components on each axis for the Blurhash algorithm. The visual result will look like a grid of `X * Y` blurred colors.

### `resize_to`

Type: `Integer` or `nil`
Default: `100`

```ruby
plugin :blurhash, resize_to: 100
plugin :blurhash, resize_to: nil
```

Before computing the Blurhash for an image, this plugin needs to extract every pixel and store them in an array. This can result in a lot of memory allocations. To avoid using too much memory, this plugin resizes the image before extracting the pixels. This should not affect the visual result.

You can either specify the target size or `nil` to disable image resizing completely.

### `extractor`

Type: `symbol` or `lambda`

```ruby
plugin :blurhash, extractor: :ruby-vips
```

Supported extractors:

| Name           | Description                                                                                                                                   |
| :-----------   | :-----------                                                                                                                                  |
| `:ruby_vips`   | Uses the [ruby-vips] gem to extract pixels from File objects. If non-file IO object is given it will be temporarily downloaded to disk.   |

You can also create your own custom pixel extractor, where you can reuse
any of the built-in analyzers. The analyzer is a lambda that accepts an IO
object and returns a `[width, height, pixels]` array containing image width, image height and all the pixels in the images in an array, or `nil` if pixels could not be extracted.

### `auto_extraction`

Type: `boolean`

- Multiple pixel extractors support, even if only VIPS is implemented right now
- Allows to resize the image before computing blurhash (to 100 pixels by default) for a faster computation
- Supports custom blurhash components parameter

## Errors

By default, any exceptions that the plugin raises while computing blurhash
will be caught and a warning will be printed out. This allows you to have the
plugin loaded even for files that are not images.

However, you can choose different strategies for handling these exceptions:

```rb
plugin :blurhash, on_error: :warn        # prints a warning (default)
plugin :blurhash, on_error: :fail        # raises the exception
plugin :blurhash, on_error: :ignore      # ignores exceptions
plugin :blurhash, on_error: -> (error) { # custom handler
  # report the exception to your exception handler
}
```

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
