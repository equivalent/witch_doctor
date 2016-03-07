module WitchDoctor
  module ApplicationHelper
    UnknownAntivirusScanState = Class.new(StandardError)

    def antivirus(resource, mount_point)
      av = resource.send("#{mount_point}_antivirus")
      if !av.scheduled?
        'Antivirus scan has not been scheduled<br>'.html_safe
      elsif !av.checked?
        'File waiting for Antivirus check<br>'.html_safe
      elsif av.clean?
        yield
      elsif av.error?
        "Antivirus scan couldn't be completed<br>".html_safe
      elsif av.infected?
        'File Contains Virus<br>'.html_safe
      else
        raise UnknownAntivirusScanState
      end
    end
  end
end
