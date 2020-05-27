# frozen_string_literal: true

require "bundler/setup"
require "minitest/autorun"
require "shrine"
require "shrine/storage/memory"
require "shrine/plugins/blurhash"

describe Shrine::Plugins::Blurhash do
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
    assert_equal "LLHLk~ja2xkBpdoKaeR*%fkCMxnj", @shrine.compute_blurhash(image)
  end

  it "allows to customize components" do
    @shrine.plugin :blurhash, components: [2, 2]
    assert_equal "AEHLk~jbpyoK", @shrine.compute_blurhash(image)
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
    assert_equal "LLHLk~ja2xkBpdoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
  end

  describe "blurhash method" do
    it "is added to UploadedFile" do
      uploaded_file = @uploader.upload(image)
      assert_equal "LLHLk~ja2xkBpdoKaeR*%fkCMxnj", uploaded_file.metadata["blurhash"]
      assert_equal "LLHLk~ja2xkBpdoKaeR*%fkCMxnj", uploaded_file.blurhash
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
end
