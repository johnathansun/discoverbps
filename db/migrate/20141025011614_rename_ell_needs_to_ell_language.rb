class RenameEllNeedsToEllLanguage < ActiveRecord::Migration
  def up
    change_column :students, :ell_needs, :string
    rename_column :students, :ell_needs, :ell_language
  end

  def down
    rename_column :students, :ell_language, :ell_needs
  end
end
