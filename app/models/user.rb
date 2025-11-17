class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :validatable
  validates :given_name, :family_name, presence: true

  has_many :recipes, dependent: :destroy
end