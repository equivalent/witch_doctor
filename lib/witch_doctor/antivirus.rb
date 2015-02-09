module WitchDoctor
  class Antivirus
    RESULTS = ['Clean', 'VirusInfected', 'FileDownloadError']
    attr_reader :resource, :mount_point

    def initialize(resource, mount_point)
      @resource = resource
      @mount_point = mount_point.to_s
    end

    def latest_scan
      resource
        .virus_scans
        .select { |vs| vs.mount_point == mount_point }
        .last
    end

    def checked?
      case latest_scan.scan_result
      when *RESULTS
        true
      else
        false
      end
    end

    def infected?
      !clean? && !error?
    end

    def error?
      throw :file_not_scaned unless checked?
      latest_scan.scan_result == 'FileDownloadError'
    end

    def clean?
      throw :file_not_scaned unless checked?
      latest_scan.scan_result == 'Clean'
    end
  end
end
