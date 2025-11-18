class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable
  validates :first_name, :last_name, presence: true

  has_many :recipes, dependent: :destroy

  has_many :my_cookbooks, dependent: :destroy
  has_many :saved_recipes, through: :my_cookbooks, source: :recipe
end