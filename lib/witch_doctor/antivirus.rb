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
      latest_scan.scan_result.present?
    end

    def infected?
      checked? && !clean? && !error?
    end

    def error?
      checked? && latest_scan.scan_result == 'FileDownloadError'
    end

    def clean?
      checked? && latest_scan.scan_result == 'Clean'
    end
  end
end
