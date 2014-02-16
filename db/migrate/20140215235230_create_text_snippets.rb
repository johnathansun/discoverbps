class CreateTextSnippets < ActiveRecord::Migration
  def change
    create_table :text_snippets do |t|
      t.string :location
      t.text :text

      t.timestamps
    end
  end
end
