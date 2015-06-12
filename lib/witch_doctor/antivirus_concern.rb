module WitchDoctor
  module AntivirusConcern
    extend ActiveSupport::Concern

    included do
      has_many :virus_scans, as: :resource
    end

    def virus_scan_scheduling_on?
      !WitchDoctor.skip_virus_scan_scheduling
    end

    module ClassMethods
      def schedule_virus_scan(options)
        mount_point = options.fetch(:on)

        after_save "schedule_#{mount_point}_virus_scan", if: ["schedule_#{mount_point}_virus_scan?", :virus_scan_scheduling_on?]
        after_destroy "unschedule_#{mount_point}_virus_scan"

        define_method("unschedule_#{mount_point}_virus_scan") do
          virus_scans.where(mount_point: mount_point.to_s).each {|vs| vs.destroy}
        end

        define_method("schedule_#{mount_point}_virus_scan") do
          virus_scans.create! do |vs|
            vs.mount_point = mount_point.to_s
          end
        end

        define_method("schedule_#{mount_point}_virus_scan?") do
          # equivalent to: (created_at_changed? && logo.present?) || (logo_changed? && logo.present?)
          (created_at_changed? && send(mount_point).present?) \
            || (send("#{mount_point}_changed?") && send(mount_point).present?)
        end

        define_method("#{mount_point}_antivirus") do
          instance_variable_get("@#{mount_point}_antivirus") \
            || instance_variable_set("@#{mount_point}_antivirus", Antivirus.new(self, mount_point))
        end
      end
    end
  end
end
