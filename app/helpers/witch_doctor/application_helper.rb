module WitchDoctor
  module ApplicationHelper
    def antivirus(resource, mount_point)
      av = resource.send("#{mount_point}_antivirus")
      if !av.checked?
        'File waiting for Antivirus check<br>'.html_safe
      elsif av.clean?
        yield
      elsif av.error?
        "Antivirus scan couldn't be completed<br>".html_safe
      else
        'File Contains Virus<br>'.html_safe
      end
    end
  end
end
