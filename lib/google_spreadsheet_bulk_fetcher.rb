require "active_support/json"
require "active_support/core_ext"
require "google_spreadsheet_bulk_fetcher/version"
require "google_spreadsheet_bulk_fetcher/config"
require "google_spreadsheet_bulk_fetcher/error"
require "google_spreadsheet_bulk_fetcher/fetcher"

module GoogleSpreadsheetBulkFetcher
  def self.config
    @config ||= Config.default_config
  end

  def self.configure
    yield config
  end
end
