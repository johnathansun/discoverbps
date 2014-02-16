class AddSlugToTextSnippets < ActiveRecord::Migration
  def change
  	add_column :text_snippets, :slug, :string
  end
end
