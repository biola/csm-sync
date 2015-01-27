module CSMSync
  class CSV
    require 'csv'

    attr_reader :rows

    def initialize(rows, file_path)
      @rows = rows
      @file_path = file_path
    end

    def columns
      rows.first.nil? ? [] : rows.first.keys
    end

    def save!
      if rows.any?
        ::CSV.open(file_path, 'w') do |csv|
          csv << columns

          rows.each do |row|
            csv << row.values
          end
        end

        file_path
      end
    end

    private

    attr_reader :file_path
  end
end
