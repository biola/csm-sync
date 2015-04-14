module CSMSync
  module Worker
    class CSVWriter
      include Sidekiq::Worker
      include Sidetiq::Schedulable

      recurrence do
        weekly.day(Settings.worker.schedule.day).hour_of_day(Settings.worker.schedule.hour)
      end

      def perform
        if Settings.worker.enabled
          file_path = Settings.csv.path
          contacts = Contact.all
          Log.info "Found #{contacts.length} contacts"

          if CSV.new(contacts.map(&:csv_attributes), file_path).save!
            Log.info "#{contacts.length} contacts saved to #{file_path}"
            sleep 2 # give the file time to be written before uploading it
            CSVUploader.perform_async(file_path)
          end
        else
          Log.warn "Worker is disabled"
        end
      end
    end
  end
end
