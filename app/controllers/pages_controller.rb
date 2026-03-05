class PagesController < ApplicationController
  def home
    if user_signed_in?
      @latest_recipes = Recipe.where(parent_id: nil)
    else
      @latest_recipes = Recipe.where(is_private: false, parent_id: nil)
    end
    @latest_recipes =  @latest_recipes.order(created_at: :desc).limit(3)
  end

  def notes
  end
  
end
