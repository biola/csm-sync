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
          if CSV.new(contacts.map(&:csv_attributes), file_path).save!
            CSVUploader.perform_async(file_path)
          end
        end
      end
    end
  end
end
