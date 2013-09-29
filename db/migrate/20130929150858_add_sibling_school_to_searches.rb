class AddSiblingSchoolToSearches < ActiveRecord::Migration
  def change
  	add_column :searches, :sibling_school_name, :string
  	add_column :searches, :sibling_school_id, :integer
  end
end
