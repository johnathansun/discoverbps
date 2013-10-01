class AddGlyphIdAndClassToPreferenceCategories < ActiveRecord::Migration
  def change
  	add_column :preference_categories, :glyph_id, :string
  	add_column :preference_categories, :glyph_class, :string
  end
end
