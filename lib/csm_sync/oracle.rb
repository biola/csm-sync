module CSMSync
  class Oracle
    def self.connection
      OCI8.new(Settings.oracle.connection_string)
    end
  end
end
