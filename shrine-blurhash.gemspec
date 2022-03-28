# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name          = "shrine-blurhash"
  gem.version       = "0.1.0"

  gem.required_ruby_version = ">= 2.5"

  gem.summary      = "Shrine plugin to compute Blurhash on image attachments"
  gem.homepage     = "https://github.com/renchap/shrine-blurhash"
  gem.authors      = ["Renaud Chaput"]
  gem.email        = ["renchap@gmail.com"]
  gem.license      = "MIT"

  gem.files        = Dir["README.md", "LICENSE.txt", "lib/**/*.rb", "shrine-blurhash.gemspec"]
  gem.require_path = "lib"

  gem.add_dependency "blurhash", "~> 0.1.4"
  gem.add_dependency "shrine", "~> 3.0"

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "ruby-vips"
end
