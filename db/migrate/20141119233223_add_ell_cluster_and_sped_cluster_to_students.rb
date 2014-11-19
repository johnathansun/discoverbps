class AddEllClusterAndSpedClusterToStudents < ActiveRecord::Migration
  def change
    add_column :students, :ell_cluster, :string
    add_column :students, :sped_cluster, :string
    add_column :students, :zone, :string
  end
end
