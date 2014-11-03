class ChangeEllLanguageToDefaultNil < ActiveRecord::Migration
  def up
    change_column :students, :ell_language, :string, default: nil
  end

  def down
  end
end
