# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_spreadsheet_bulk_fetcher/version'

Gem::Specification.new do |spec|
  spec.name          = "google_spreadsheet_bulk_fetcher"
  spec.version       = GoogleSpreadsheetBulkFetcher::VERSION
  spec.authors       = ["Yuya Yokosuka"]
  spec.email         = ["yuya.yokosuka@gmail.com"]

  spec.summary       = %q{Google Spreadsheet bulk fetcher}
  spec.description   = %q{Google Spreadsheet bulk fetcher}
  spec.homepage      = "https://github.com/YuyaYokosuka/google_spreadsheet_bulk_fetcher"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'google-api-client', '~> 0.9'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end