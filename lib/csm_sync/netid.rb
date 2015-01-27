require 'dbm'

module CSMSync
  module NetID
    def self.lookup(id_number)
      id_number = id_number.to_s

      store[id_number] || store[id_number] = ws_lookup(id_number)
    end

    private

    def self.store
      @store ||= DBM.open('./tmp/netids', 0660, DBM::WRCREAT)
    end

    def self.ws_lookup(id_number)
      netid = BiolaWebServices.dirsvc.get_user!(id: id_number)['netid']
      netid
    end
  end
end
