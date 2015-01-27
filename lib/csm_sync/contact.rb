module CSMSync
  class Contact
    SQL = 'SELECT id, lname, fname, mname, gender, race, alumnus, email, cell, perm_street_line1, perm_street_line2, perm_city, perm_state, perm_zip, perm_nation, grad_date, applicant_type, class_level, college, degree, major, concentration, admit_term, student_type
FROM bsv_csm_student
UNION
SELECT id, lname, fname, mname, gender, race, alumnus, email, cell, perm_street_line1, perm_street_line2, perm_city, perm_state, perm_zip, perm_nation, grad_date, applicant_type, NULL, college, degree, major, concentration, NULL, NULL
FROM bsv_csm_alumni
WHERE id NOT IN(SELECT id FROM bsv_csm_student)'
    ARRAY_SEPARATOR = '|'

    attr_accessor :first_name, :middle_name, :last_name,
                  :gender, :race,
                  :id_number,
                  :email, :cell,
                  :street1, :street2, :city, :state, :zip, :country,
                  :alumnus, :source, :student_type, :admittance_term, :graduation_date, :class_level,
                  :school, :major, :degree, :concentration

    # Banner view fields
    alias :id= :id_number=
    alias :lname= :last_name=
    alias :fname= :first_name=
    alias :mname= :middle_name=
    # gender
    # race
    # alumnus
    # email
    # cell
    alias :perm_street_line1= :street1=
    alias :perm_street_line2= :street2=
    alias :perm_city= :city=
    alias :perm_state= :state=
    alias :perm_zip= :zip=
    alias :perm_nation= :country=
    alias :grad_date= :graduation_date=
    alias :applicant_type= :source=
    # class_level
    alias :college= :school=
    # degree
    # major
    # concentration
    alias :admit_term= :admittance_term=
    # student_type

    # CSV fields
    # cas_username: see below
    alias :student_id :id_number

    def initialize(attributes = {})
      attributes.each do |att, val|
        meth = "#{att}=".downcase.to_sym
        send(meth, val) if self.class.writable_attributes.include?(meth)
      end
    end

    def middle_initial
      middle_name.to_s[0]
    end

    def full_name
      "#{first_name} #{last_name}".strip
    end

    def netid
      NetID.lookup(id_number)
    end
    alias :cas_username :netid

    def student?
      source == 'STUDENT'
    end

    def alumnus?
      alumnus == 'Y'
    end

    def contact_type
      [].tap { |a|
        a << 'Current Student' if student?
        a << 'Alumni' if alumnus?
      }.join(ARRAY_SEPARATOR)
    end

    def graduation_date
      @graduation_date.strftime('%m/%d/%Y') unless @graduation_date.nil?
    end

    # picklist mapping
    [:race, :class_level, :college, :degree, :major].each do |att|
      define_method(att) do
        value = instance_variable_get("@#{att}")
        Settings.picklists[att][value] || value
      end
    end

    def csv_attributes
      {
        'CAS Username' => cas_username,
        'Student ID' => id_number,
        'Full Name' => full_name,
        'First Name' => first_name,
        'MI' => middle_initial,
        'Last Name' => last_name,
        'Gender' => gender,
        'Ethnicity' => race,
        'Alumnus' => alumnus?,
        'Student' => student?,
        'Primary Email' => email,
        'Cell Phone' => cell,
        'Permanent Street Address 1' => street1,
        'Permanent Street Address 2' => street2,
        'Permanent City' => city,
        'Permanent State/Province' => state,
        'Permanent Zip Code/Postal Code' => zip,
        'Permanent Country' => country,
        'Admittance Term' => admittance_term,
        'Graduation Date' => graduation_date,
        'Class Level' => class_level,
        'Student Type' => student_type,
        'Applicant Type' => contact_type,
        'School' => school,
        'Degree' => degree,
        'Major' => major,
        'Concentration' => concentration
      }
    end

    def to_s
      "#{first_name} #{last_name}"
    end

    def self.all
      [].tap do |contacts|
        # TODO: limit to only alumni with netids... probably. Need clarification from Mark/Symplicity.
        cursor = Oracle.connection.exec(SQL)
        while row = cursor.fetch_hash
          contacts << new(row)
        end
      end
    end

    def self.writable_attributes
      @writable_attributes ||= new.methods.grep(/\=\Z/) - Object.new.methods
    end
  end
end
