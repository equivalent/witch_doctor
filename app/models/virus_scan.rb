class VirusScan < ActiveRecord::Base
  TokenNotSpecified = Class.new(StandardError)

  class << self
    attr_writer :token

    def token
      @token || raise(TokenNotSpecified)
    end
  end

  attr_accessible :scan_result, :scanned_at, :mount_point
  attr_accessible :scan_result, as: :scan_update

  belongs_to :resource, polymorphic: true
  scope :not_scanned, -> { where scan_result: nil }
  validates_inclusion_of :scan_result, in: WitchDoctor::Antivirus::RESULTS, allow_nil: true

  before_update :set_scanned_at, if: :scan_updated?

  def as_json(options={})
    attributes
      .slice('id', 'scan_result', 'scanned_at')
      .tap { |hash|
        hash.merge!('file_url' => file_url)
      }
  end

  # S3 will give url, file wil show mount point, we care just about s3
  def file_url
    resource.send(mount_point).url
  end

  def set_scanned_at
    self.scanned_at = Time.now
  end

  def scan_updated?
    scan_result.in? WitchDoctor::Antivirus::RESULTS
  end
end
