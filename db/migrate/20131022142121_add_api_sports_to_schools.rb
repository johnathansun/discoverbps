class AddApiSportsToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :api_sports, :text
  end
end
