class Recipe < ApplicationRecord
  belongs_to :user
  validates :title, :instructions, :prep_time, :cook_time, presence: true
  validates :prep_time, :cook_time, numericality: { greater_than: 0 }

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags

  has_many :my_cookbooks, dependent: :destroy
  has_many :users_who_saved, through: :my_cookbooks, source: :user
end
