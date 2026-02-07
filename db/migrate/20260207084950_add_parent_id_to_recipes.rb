class AddParentIdToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :parent_id, :integer
    add_index :recipes, :parent_id
  end
end
