class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable
  validates :first_name, :last_name, presence: true

  has_many :recipes, dependent: :destroy
end