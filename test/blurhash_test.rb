# frozen_string_literal: true

require "bundler/setup"
require "minitest/autorun"
require "shrine"
require "shrine/storage/memory"
require "shrine/plugins/blurhash"

describe Shrine::Plugins::Blurhash do
  describe :ruby_vips do
    before do
      uploader_class = Class.new(Shrine)

      uploader_class.storages[:cache] = Shrine::Storage::Memory.new
      uploader_class.storages[:store] = Shrine::Storage::Memory.new
      uploader_class.class_eval { plugin :blurhash, extractor: :ruby_vips }

      @shrine = uploader_class
      @uploader = uploader_class.new(:store)
    end

    def image
      File.open("test/fixtures/image1.jpg", binmode: true)
    end

    it "computes the correct blurhash with default options" do
      assert_equal "LLHLk~jZ2xkBpdoKaeR*%fkCMxnj", @shrine.compute_blurhash(image)
    end

    it "allows to customize components" do
      @shrine.plugin :blurhash, components: [2, 2]
      assert_equal "AEHLk~jZpyoK", @shrine.compute_blurhash(image)
    end

    it "allows passing a proc to calculate components" do
      @shrine.plugin :blurhash, components: ->(_w, _h) { [2, 2] }
      assert_equal "AEHLk~jZpyoK", @shrine.compute_blurhash(image)
    end

    it "allows to customize resize dimensions" do
      @shrine.plugin :blurhash, resize_to: 200
      assert_equal "LLHV6naf2xk9lAoKaeR*%fkBMxn*", @shrine.compute_blurhash(image)
    end

    it "allows to not resize before computing blurhash" do
      @shrine.plugin :blurhash, resize_to: nil
      assert_equal "LLHV6nae2ek8lAo0aeR*%fkCMxn%", @shrine.compute_blurhash(image)
    end

    it "automatically computes the blurhash on upload" do
      uploaded_file = @uploader.upload(image)
      assert_equal "LLHLk~jZ2xkBpdoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
    end

    describe "blurhash method" do
      it "is added to UploadedFile" do
        uploaded_file = @uploader.upload(image)
        assert_equal "LLHLk~jZ2xkBpdoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
        assert_equal "LLHLk~jZ2xkBpdoKaeR*%fkCMxnj", uploaded_file.blurhash
      end

      it "allows a nil blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata["blurhash"] = nil
        assert_nil uploaded_file.blurhash
      end

      it "allows a missing blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata.delete("blurhash")
        assert_nil uploaded_file.blurhash
      end
    end

    describe "auto_extraction: false" do
      it "does not add metadata" do
        @shrine.plugin :blurhash, auto_extraction: false
        uploaded_file = @uploader.upload(image)
        assert_nil uploaded_file.metadata["blurhash"]
      end

      it "provides method to compute blurhash from files" do
        assert_equal "LLHLk~jZ2xkBpdoKaeR*%fkCMxnj", @shrine.compute_blurhash(image)
      end
    end
  end

  describe :mini_magick do
    before do
      uploader_class = Class.new(Shrine)

      uploader_class.storages[:cache] = Shrine::Storage::Memory.new
      uploader_class.storages[:store] = Shrine::Storage::Memory.new
      uploader_class.class_eval { plugin :blurhash, extractor: :mini_magick }

      @shrine = uploader_class
      @uploader = uploader_class.new(:store)
    end

    def image
      File.open("test/fixtures/image1.jpg", binmode: true)
    end

    it "computes the correct blurhash with default options" do
      assert_equal "LLHLk~ja2xkBpeoKaeR*%fkCMxnj", @shrine.compute_blurhash(image)
    end

    it "allows to customize components" do
      @shrine.plugin :blurhash, components: [2, 2]
      assert_equal "AFHLk~jau6oK", @shrine.compute_blurhash(image)
    end

    it "allows passing a proc to calculate components" do
      @shrine.plugin :blurhash, components: ->(_w, _h) { [2, 2] }
      assert_equal "AFHLk~jau6oK", @shrine.compute_blurhash(image)
    end

    it "allows to customize resize dimensions" do
      @shrine.plugin :blurhash, resize_to: 200
      assert_equal "LLHV6naf2ek9pdo1aeR*%fkCMxn%", @shrine.compute_blurhash(image)
    end

    it "allows to not resize before computing blurhash" do
      @shrine.plugin :blurhash, resize_to: nil
      assert_equal "LLHV6nae2ek8lAo0aeR*%fkCMxn%", @shrine.compute_blurhash(image)
    end

    it "automatically computes the blurhash on upload" do
      uploaded_file = @uploader.upload(image)
      assert_equal "LLHLk~ja2xkBpeoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
    end

    describe "blurhash method" do
      it "is added to UploadedFile" do
        uploaded_file = @uploader.upload(image)
        assert_equal "LLHLk~ja2xkBpeoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
        assert_equal "LLHLk~ja2xkBpeoKaeR*%fkCMxnj", uploaded_file.blurhash
      end

      it "allows a nil blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata["blurhash"] = nil
        assert_nil uploaded_file.blurhash
      end

      it "allows a missing blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata.delete("blurhash")
        assert_nil uploaded_file.blurhash
      end
    end

    describe "auto_extraction: false" do
      it "does not add metadata" do
        @shrine.plugin :blurhash, auto_extraction: false
        uploaded_file = @uploader.upload(image)
        assert_nil uploaded_file.metadata["blurhash"]
      end

      it "provides method to compute blurhash from files" do
        assert_equal "LLHLk~ja2xkBpeoKaeR*%fkCMxnj", @shrine.compute_blurhash(image)
      end
    end
  end

  describe :rmagick do
    before do
      uploader_class = Class.new(Shrine)

      uploader_class.storages[:cache] = Shrine::Storage::Memory.new
      uploader_class.storages[:store] = Shrine::Storage::Memory.new
      uploader_class.class_eval { plugin :blurhash, extractor: :rmagick }

      @shrine = uploader_class
      @uploader = uploader_class.new(:store)
    end

    def image
      File.open("test/fixtures/image1.jpg", binmode: true)
    end

    it "computes the correct blurhash with default options" do
      assert_equal "L2HVC+X}jBwz^$OFOtT0w7AdyBtQ", @shrine.compute_blurhash(image)
    end

    it "allows to customize components" do
      @shrine.plugin :blurhash, components: [2, 2]
      assert_equal "A2HVC+X}^$OF", @shrine.compute_blurhash(image)
    end

    it "allows passing a proc to calculate components" do
      @shrine.plugin :blurhash, components: ->(_w, _h) { [2, 2] }
      assert_equal "A2HVC+X}^$OF", @shrine.compute_blurhash(image)
    end

    it "allows to customize resize dimensions" do
      @shrine.plugin :blurhash, resize_to: 200
      assert_equal "L0HetW?Z$J:3~q,:v:pqUAq^H*X8", @shrine.compute_blurhash(image)
    end

    it "allows to not resize before computing blurhash" do
      @shrine.plugin :blurhash, resize_to: nil
      assert_equal "LLHV6nae2ek8lAo0aeR*%fkCMxn%", @shrine.compute_blurhash(image)
    end

    it "automatically computes the blurhash on upload" do
      uploaded_file = @uploader.upload(image)
      assert_equal "L2HVC+X}jBwz^$OFOtT0w7AdyBtQ", uploaded_file.metadata["blurhash"]
    end

    describe "blurhash method" do
      it "is added to UploadedFile" do
        uploaded_file = @uploader.upload(image)
        assert_equal "L2HVC+X}jBwz^$OFOtT0w7AdyBtQ", uploaded_file.metadata["blurhash"]
        assert_equal "L2HVC+X}jBwz^$OFOtT0w7AdyBtQ", uploaded_file.blurhash
      end

      it "allows a nil blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata["blurhash"] = nil
        assert_nil uploaded_file.blurhash
      end

      it "allows a missing blurhash metadata" do
        uploaded_file = @uploader.upload(image)
        uploaded_file.metadata.delete("blurhash")
        assert_nil uploaded_file.blurhash
      end
    end

    describe "auto_extraction: false" do
      it "does not add metadata" do
        @shrine.plugin :blurhash, auto_extraction: false
        uploaded_file = @uploader.upload(image)
        assert_nil uploaded_file.metadata["blurhash"]
      end

      it "provides method to compute blurhash from files" do
        assert_equal "L2HVC+X}jBwz^$OFOtT0w7AdyBtQ", @shrine.compute_blurhash(image)
      end
    end
  end
end