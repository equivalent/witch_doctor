module WitchDoctor
  class Antivirus
    RESULTS = ['Clean', 'VirusInfected', 'FileDownloadError']
    attr_reader :resource, :mount_point

    def initialize(resource, mount_point)
      @resource = resource
      @mount_point = mount_point.to_s
    end

    def latest_scan
      @latest_scan ||= resource
        .virus_scans
        .select { |vs| vs.mount_point == mount_point }
        .last
    end

    def scheduled?
      !latest_scan.nil?
    end

    def checked?
      scheduled? && latest_scan.scan_result.present?
    end

    def infected?
      checked? && latest_scan.scan_result == 'VirusInfected'
    end

    def error?
      checked? && latest_scan.scan_result == 'FileDownloadError'
    end

    def clean?
      checked? && latest_scan.scan_result == 'Clean'
    end
  end
end
