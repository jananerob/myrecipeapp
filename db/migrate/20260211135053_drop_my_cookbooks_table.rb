class DropMyCookbooksTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :my_cookbooks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end