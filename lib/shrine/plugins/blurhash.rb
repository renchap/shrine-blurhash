# frozen_string_literal: true

require "blurhash"

class Shrine
  module Plugins
    module Blurhash
      LOG_SUBSCRIBER = lambda do |event|
        Shrine.logger.info "Blurhash (#{event.duration}ms) – #{{
          io: event[:io].class,
          uploader: event[:uploader],
        }.inspect}"
      end

      def self.configure(uploader, log_subscriber: LOG_SUBSCRIBER, **opts)
        uploader.opts[:blurhash] ||= {
          extractor: :ruby_vips,
          on_error: :warn,
          resize_to: 100,
          components: [4, 3],
        }
        uploader.opts[:blurhash].merge!(opts)

        # resolve error strategy
        uploader.opts[:blurhash][:on_error] =
          case uploader.opts[:blurhash][:on_error]
          when :fail   then ->(error) { raise error }
          when :warn   then ->(error) { Shrine.warn "Error occurred when attempting to extract blurhash: #{error.inspect}" }
          when :ignore then ->(error) {}
          else
            uploader.opts[:blurhash][:on_error]
          end

        uploader.subscribe(:blurhash, &log_subscriber) if uploader.respond_to?(:subscribe)
      end

      module ClassMethods
        def compute_blurhash(io)
          extractor = opts[:blurhash][:extractor]
          extractor = pixels_extractor(extractor) if extractor.is_a?(Symbol)

          resize_to = opts[:blurhash][:resize_to]
          args = [io, resize_to, pixels_extractors].take(extractor.arity.abs)

          blurhash = instrument_blurhash(io) do
            pixels = extractor.call(*args)

            components = opts[:blurhash][:components]
            ::Blurhash.encode(pixels[:width], pixels[:height], pixels[:pixels], x_comp: components[0], y_comp: components[1])
          end

          io.rewind

          blurhash
        end

        # Returns a hash of built-in pixels extractors, where keys are
        # extractors names and values are `#call`-able objects which accepts the
        # IO object.
        def pixels_extractors
          @pixels_extractors ||= PixelsExtractor::SUPPORTED_EXTRACTORS.inject({}) do |hash, tool|
            hash.merge!(tool => pixels_extractor(tool))
          end
        end

        # Returns callable pixels extractor object.
        def pixels_extractor(name)
          on_error = opts[:blurhash][:on_error]

          PixelsExtractor.new(name, on_error: on_error).method(:call)
        end

        private

        # Sends a `blurhash.shrine` event for instrumentation plugin.
        def instrument_blurhash(io, &block)
          return yield unless respond_to?(:instrument)

          instrument(:blurhash, io: io, &block)
        end
      end

      module InstanceMethods
        def extract_metadata(io, **options)
          blurhash = self.class.compute_blurhash(io)

          super.merge!("blurhash" => blurhash)
        end
      end

      module FileMethods
        def blurhash
          metadata["blurhash"]
        end
      end

      class PixelsExtractor
        SUPPORTED_EXTRACTORS = [:ruby_vips].freeze

        def initialize(tool, on_error: method(:fail))
          unless SUPPORTED_EXTRACTORS.include?(tool)
            raise Error, "unknown pixel extractor #{tool.inspect}, supported extractors are: #{SUPPORTED_EXTRACTORS.join(',')}"
          end

          @tool     = tool
          @on_error = on_error
        end

        def call(io, resize_to)
          dimensions = send(:"extract_with_#{@tool}", io, resize_to)
          io.rewind
          dimensions
        end

        private

        def extract_with_ruby_vips(io, resize_to)
          require "vips"

          begin
            Shrine.with_file(io) do |file|
              image = Vips::Image.new_from_file(file.path, access: :sequential)
              image = image.resize(resize_to.fdiv(image.width), vscale: resize_to.fdiv(image.height)) if resize_to

              {
                width: image.width,
                height: image.height,
                pixels: image.to_a.flatten,
              }
            end
          rescue Vips::Error => e
            on_error(e)
          end
        end

        def on_error(error)
          @on_error.call(error)
          nil
        end
      end
    end

    register_plugin(:blurhash, Blurhash)
  end
end
