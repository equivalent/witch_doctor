class Document < ActiveRecord::Base
  include WitchDoctor::AntivirusConcern
  # AntivirusConcern, #schedule_file_virus_scan
  schedule_virus_scan on: :attachment

  def attachment
    # this is dummy carrierwave-like impementation
    # this can be anything as long as it repsonce to url
    OpenStruct.new(url: "https://my-s3-bucket.dummy/uploads/documents/#{super}")
  end
end
