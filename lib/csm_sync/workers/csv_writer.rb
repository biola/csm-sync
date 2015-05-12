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
          Log.info "Starting Sync"
          file_path = Settings.csv.path

          # Delete the old csv before creating a new one
          if File.exists?(file_path)
            File.unlink file_path
            Log.info "Deleted Old CSV: #{file_path}"
          end

          contacts = Contact.all.select{|c| c.email.present?}
          Log.info "Found #{contacts.length} contacts"

          if CSV.new(contacts.map(&:csv_attributes), file_path).save!
            Log.info "#{contacts.length} contacts saved to #{file_path}"
            # It would be nice to run this asynchronously but in a load balanced situation
            # we can't guarantee that the file wasn't written onto a different server.
            # Until we have a shared files directory, this is the best workaround.
            CSVUploader.new.perform(file_path)
          end
        else
          Log.warn "Worker is disabled"
        end
      end
    end
  end
end
