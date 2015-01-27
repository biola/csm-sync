module CSMSync
  module Worker
    class UploadError < StandardError; end

    class CSVUploader
      include Sidekiq::Worker

      def perform(file_path)
        # TODO

        # raise UploadError, "#{}" unless successful?(nil)
      end

      private

      def successful?(response)
        # TODO
      end
    end
  end
end

