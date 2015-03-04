require "witch_doctor/engine"
require "witch_doctor/antivirus"
require "witch_doctor/antivirus_concern"

module WitchDoctor
  class << self
    attr_writer :time_stamper

    def time_stamper
      @time_stamper ||= -> { Time.now }
    end
  end
end
