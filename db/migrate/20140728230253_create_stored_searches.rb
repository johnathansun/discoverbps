class CreateStoredSearches < ActiveRecord::Migration
  def change
    create_table :stored_searches do |t|
      t.text :json

      t.timestamps
    end
  end
end
