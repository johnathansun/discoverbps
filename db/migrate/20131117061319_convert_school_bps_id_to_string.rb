class ConvertSchoolBpsIdToString < ActiveRecord::Migration
  def up
  	change_column :schools, :bps_id, :string
  end

  def down
		change_column :schools, :bps_id, :integer
  end
end
