class CreateMyCookbooks < ActiveRecord::Migration[7.1]
  def change
    create_table :my_cookbooks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
