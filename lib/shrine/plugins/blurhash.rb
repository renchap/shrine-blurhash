class Shrine
  module Plugins
    module Blurhash
      LOG_SUBSCRIBER = ->(event) do
        Shrine.logger.info "Blurhash (#{event.duration}ms) – #{{
          io: event[:io].class,
          uploader: event[:uploader],
        }.inspect}"
      end

      def self.configure(uploader, log_subscriber: LOG_SUBSCRIBER, **_opts)
        uploader.subscribe(:blurhash, &log_subscriber) if uploader.respond_to?(:subscribe)
      end

      module ClassMethods
        def compute_blurhash(io)
          "aaaa"
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
    end

    register_plugin(:blurhash, Blurhash)
  end
end
