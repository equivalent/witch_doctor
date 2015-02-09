module WitchDoctor
  module ApplicationHelper
    def antivirus(resource, mount_point)
      catch(:file_not_scaned) do
        if (av = resource.send("#{mount_point}_antivirus")) && av.clean?
          yield
        elsif av.error?
          "Antivirus scan couldn't be completed"
        else
          'File Contains Virus'
        end
      end || 'File waiting for Antivirus check'
    end
  end
end
