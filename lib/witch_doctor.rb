require "witch_doctor/engine"
require "witch_doctor/antivirus"
require "witch_doctor/antivirus_concern"

module WitchDoctor
  TokenNotSpecified = Class.new(StandardError)

  class << self
    attr_writer :time_stamper, :virus_scan_limit, :token,
      :skip_virus_scan_scheduling, :controller_object_hash_generator

    def time_stamper
      @time_stamper ||= -> { Time.now }
    end

    def virus_scan_limit
      @virus_scan_limit ||= 10
    end

    def token
      @token || raise(TokenNotSpecified)
    end

    def skip_virus_scan_scheduling
      !!@skip_virus_scan_scheduling
    end

    def controller_object_hash_generator
      @controller_object_hash_generator ||= begin
        -> (object) { { json: { data: object.as_json } } }
      end
    end
  end
end
