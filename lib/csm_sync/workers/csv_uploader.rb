module CSMSync
  module Worker
    class CSVUploader
      include Sidekiq::Worker

      FILE_NAME = 'csm_export.csv'
      TIMEOUT = 60 * 5 # 5 min

      def perform(file_path)
        # A bad password triggers a password prompt that will just sit there. So we need to trigger a timeout if it goes too long.
        Timeout.timeout(TIMEOUT) do
          # Net::SCP seems to just return nil on sucess and always raise an erorr on failure. So not much to check here.
          Net::SCP.upload!(Settings.upload.host, Settings.upload.username, file_path, FILE_NAME, ssh: {password: Settings.upload.password})
        end

        File.unlink file_path
      end
    end
  end
end

