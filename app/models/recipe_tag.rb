class RecipeTag < ApplicationRecord
  belongs_to :recipe
  belongs_to :tag
  
  validates :tag_id, uniqueness: { scope: :recipe_id, message: "This tag is already assigned to this recipe." }
end
