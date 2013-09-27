class AddNameAndBpsIdToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :name, :string
  	add_column :schools, :bps_id, :integer
  end
end
