require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'shellwords'

module GoogleSpreadsheetBulkFetcher
  class Fetcher
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

    # @param [String] spreadsheet_id
    # @param [String] user_id
    # @param [GoogleSpreadsheetBulkFetcher::Config] config
    # @param [String] application_name
    def initialize(spreadsheet_id, user_id, config: nil, application_name: nil)
      @spreadsheet_id = spreadsheet_id
      @user_id = user_id
      @config = config || GoogleSpreadsheetBulkFetcher.config
      @application_name = application_name

      @spreadsheet = nil
    end

    def fetch
      @spreadsheet = service.get_spreadsheet(@spreadsheet_id, fields: 'sheets(properties,data.rowData.values(formattedValue))')
      self
    end

    # @param [Integer] index
    # @param [Integer] sheet_id
    # @param [String] title
    # @param [Integer] skip
    # @param [Boolean] structured
    def all_rows_by!(index: nil, sheet_id: nil, title: nil, skip: 0, structured: false)
      sheet = sheet_by!(index: index, sheet_id: sheet_id, title: title)
      sheet_to_array(sheet, skip: skip, structured: structured)
    end

    def service
      @service ||= Google::Apis::SheetsV4::SheetsService.new.tap do |service|
        service.authorization = fetch_credentials
        service.client_options.application_name = @application_name if @application_name.present?
      end
    end

    private

    def sheet_by!(index: nil, sheet_id: nil, title: nil)
      raise SpreadsheetNotFound if @spreadsheet.sheets.blank?

      if index.present?
        return @spreadsheet.sheets.find { |sheet| sheet.properties.index == index }
      elsif sheet_id.present?
        return @spreadsheet.sheets.find { |sheet| sheet.properties.sheet_id == sheet_id }
      elsif title.present?
        return @spreadsheet.sheets.find { |sheet| sheet.properties.title == title }
      end

      raise SheetNotFound
    end

    def sheet_to_array(sheet, skip: 0, structured: false)
      sheet_data = sheet&.data&.first
      return [] if sheet_data.nil?

      rows = sheet_data.row_data.map do |row_data|
        values = row_data.values
        next [''] if values.nil?

        values.map { |cell| cell&.formatted_value || "" }
      end

      headers = rows.first
      count = headers.count

      if structured
        rows.delete_at(0)
        rows.slice!(0, skip)
        rows.map { |r| headers.zip(r).to_h }
      else
        rows.slice!(0, skip)
        rows.map { |r| fill_array(r, count) }
      end
    end

    def fetch_credentials
      client_id = Google::Auth::ClientId.from_file(@config.client_secrets_file)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: @config.credential_store_file)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, @config.scopes, token_store)

      credentials = authorizer.get_credentials(@user_id)
      return credentials if credentials.present?

      url = authorizer.get_authorization_url(base_url: OOB_URI)
      escaped_url = url.shellescape
      system("open #{escaped_url}")
      puts "Open #{url} in your browser and enter the resulting code: "
      code = STDIN.gets
      authorizer.get_and_store_credentials_from_code(user_id: @user_id, code: code, base_url: OOB_URI)
    end

    def fill_array(items, count, fill: '')
      items + (count - items.count).times.map { fill }
    end
  end
end
