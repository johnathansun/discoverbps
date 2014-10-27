class SetSpedNeedsDefaultToFalse < ActiveRecord::Migration
  def up
    change_column :students, :sped_needs, :boolean, default: false
  end

  def down
  end
end
