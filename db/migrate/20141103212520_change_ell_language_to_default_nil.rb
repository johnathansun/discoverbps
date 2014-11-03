class ChangeEllLanguageToDefaultNil < ActiveRecord::Migration
  def up
    change_column :students, :ell_language, :string
  end

  def down
  end
end
