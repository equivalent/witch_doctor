class CreateWitchDoctorVirusScans < ActiveRecord::Migration
  def up
    unless ActiveRecord::Base.connection.table_exists? 'virus_scans'
      create_table :virus_scans do |t|
        t.string :resource_type
        t.integer :resource_id
        t.string :scan_result
        t.string :mount_point
        t.datetime :scanned_at

        t.timestamps
      end
    end
  end

  def down
    drop_table :virus_scans
  end
end
