module WitchDoctor
  class VirusScan < ActiveRecord::Base
    self.table_name = "virus_scans"

    belongs_to :resource, polymorphic: true
    scope :not_scanned, -> { where scan_result: nil }
    validates_inclusion_of :scan_result, in: WitchDoctor::Antivirus::RESULTS, allow_nil: true

    before_update :set_scanned_at, if: :scan_updated?

    def as_json(options={})
      attributes
        .slice('id', 'scan_result')
        .tap { |hash|
          hash.merge!('file_url'   => file_url,
                      'scanned_at' => scanned_at.try(:utc).try(:iso8601))
        }
    end

    # S3 will give url, file wil show mount point, we care just about s3
    def file_url
      resource.send(mount_point).url
    end

    def set_scanned_at
      self.scanned_at = WitchDoctor.time_stamper.call
    end

    def scan_updated?
      scan_result.in? WitchDoctor::Antivirus::RESULTS
    end
  end
end
