class VirusScanPermitter
  def attributes(params)
    params
      .require(:virus_scan)
      .permit [:scan_result]
  end
end
