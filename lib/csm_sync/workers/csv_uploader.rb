module CSMSync
  module Worker
    class CSVUploader
      include Sidekiq::Worker

      FILE_NAME = 'csm_export.csv'
      TIMEOUT = 60 * 5 # 5 min

      def perform(file_path)
        # net-ssh uses File.expand_path which will thow a "non-absolute home" error if HOME isn't an absolute path.
        ENV['HOME'] = Dir.pwd

        # A bad password triggers a password prompt that will just sit there. So we need to trigger a timeout if it goes too long.
        Timeout.timeout(TIMEOUT) do
          Log.info "Uploading #{file_path} to #{Settings.upload.host}..."
          # Net::SCP seems to just return nil on sucess and always raise an erorr on failure. So not much to check here.
          Net::SCP.upload!(Settings.upload.host, Settings.upload.username, file_path, FILE_NAME, ssh: {password: Settings.upload.password})
          Log.info "Finished uploading #{file_path} to #{Settings.upload.host}"
        end
      end
    end
  end
end
