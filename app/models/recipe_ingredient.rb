class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  enum unit: {
    ml: 0,
    g: 1,  
    kg: 2, 
    l: 3,  
    pc: 4, 
    cup: 5, 
    tbsp: 6, 
    tsp: 7, 
    pinch: 8
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
  validates :ingredient_id, presence: true
end
