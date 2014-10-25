class DropIepColumn < ActiveRecord::Migration
  def up
    remove_column :students, :iep
  end

  def down
    add_column :students, :iep, :string
  end
end
