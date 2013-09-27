class AddSlugToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :slug, :string
  	add_index :schools, :slug, unique: true
  end
end
