class Recipe < ApplicationRecord
  has_one_attached :image, dependent: :purge_later

  attr_accessor :remove_image, :recalculate_calories

  belongs_to :user
  validates :title, :instructions, :prep_time, :cook_time, presence: true
  validates :prep_time, :cook_time, numericality: { greater_than: 0 }

  belongs_to :parent, class_name: "Recipe", optional: true
  has_many :copies, class_name: "Recipe", foreign_key: "parent_id"

  has_many :recipe_ingredients, dependent: :destroy
  validates_associated :recipe_ingredients

  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  
  def duplicate_for(new_user)
    new_recipe = self.dup
    new_recipe.user = new_user
    new_recipe.parent_id = self.id 
    new_recipe.edited_by_copyist = false

    self.recipe_ingredients.each do |ri|
     new_recipe.recipe_ingredients.build(
      ingredient_id: ri.ingredient_id,
      amount: ri.amount,
      unit: ri.unit
     )       
    end

    if self.image.attached?
      new_recipe.image.attach(
        io: StringIO.new(self.image.download),
        filename: self.image.filename,
        content_type: self.image.content_type
        )
    end

    new_recipe
  end

end
