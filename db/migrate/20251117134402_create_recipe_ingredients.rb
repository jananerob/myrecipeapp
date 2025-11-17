class CreateRecipeIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.float :amount
      t.integer :unit

      t.timestamps
    end
  end
end
