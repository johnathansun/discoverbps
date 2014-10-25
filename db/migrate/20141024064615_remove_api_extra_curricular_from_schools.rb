class RemoveApiExtraCurricularFromSchools < ActiveRecord::Migration
  def up
    remove_column :schools, :api_extra_curricular
  end

  def down
    add_column :schools, :api_extra_curricular, :text
  end
end
