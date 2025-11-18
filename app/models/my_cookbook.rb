class MyCookbook < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :recipe_id, uniqueness: { scope: :user_id, message: "You already have this recipe in your cookbook." }
end
