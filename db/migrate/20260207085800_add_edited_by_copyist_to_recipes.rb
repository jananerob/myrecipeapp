class AddEditedByCopyistToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :edited_by_copyist, :boolean, default: false, null: false
  end
end
