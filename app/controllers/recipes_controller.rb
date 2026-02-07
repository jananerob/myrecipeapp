class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :save_to_cookbook, :remove_from_cookbook]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  
  # GET /recipes
  def index
    @recipes = Recipe.where(is_private: false)
    if user_signed_in? 
      @recipes = @recipes.or(Recipe.where(user: current_user))
    end
  end

  def my_recipes
    @recipes = current_user.recipes
  end

  def save_to_cookbook
    current_user.my_cookbooks.create!(recipe: @recipe)

    redirect_to @recipe, notice: "Recipe was successfully saved to your cookbook."

  rescue ActiveRecord::RecordInvalid

    redirect_to @recipe, alert: "Recipe has already been saved to your cookbook."
  end

  def remove_from_cookbook
    current_user.my_cookbooks.find_by!(recipe: @recipe).destroy

    redirect_to @recipe, notice: "Recipe was successfully removed from your cookbook."
  end
  def cookbook
    @recipes = current_user.saved_recipes
  end
  # GET /recipes/1
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes
  def create
    ingredient_data = params.dig(:recipe, :recipe_ingredients_data) || []

    Recipe.transaction do 
      @recipe = current_user.recipes.build(recipe_params)
      @recipe.save!
      process_ingredients_for(@recipe)
      redirect_to @recipe, notice: "Recipe was successfully created."
    end

  rescue ActiveRecord::RecordInvalid => e
    @recipe.recipe_ingredients.target.clear

    ingredient_data.each do |data|
      @recipe.recipe_ingredients.build(data.permit(:ingredient_id, :amount, :unit))
    end
    
    if e.record.is_a?(RecipeIngredient)
      @recipe.errors.add(:base, "Ingredient error: #{e.record.errors.full_messages.to_sentence}")
    end
    
    render :new, status: :unprocessable_entity
  end

  # PATCH/PUT /recipes/1
  def update
    ingredient_data = params.dig(:recipe, :recipe_ingredients_data) || []

    Recipe.transaction do
      @recipe.update!(recipe_params)
        process_ingredients_for(@recipe)

        @recipe.image.purge if params[:recipe][:remove_image] == '1'
        
        redirect_to @recipe, notice: "Recipe was successfully updated.", status: :see_other
      end

  rescue ActiveRecord::RecordInvalid => e

    @recipe.recipe_ingredients.target.clear

    ingredient_data.each do |data|
      @recipe.recipe_ingredients.build(data.permit(:ingredient_id, :amount, :unit))
    end

    if e.record.is_a?(RecipeIngredient)
      @recipe.errors.add(:base, "Ingredient error: #{e.record.errors.full_messages.to_sentence}")
    end

    render :edit, status: :unprocessable_entity    
  end

  # DELETE /recipes/1
  def destroy
    @recipe.destroy!
    redirect_to recipes_url, notice: "Recipe was successfully destroyed.", status: :see_other
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def authorize_owner!
    redirect_to recipes_path, alert: "You are not authorized to perform this action." unless @recipe.user == current_user 
  end  

  # Only allow a list of trusted parameters through.
  def recipe_params
    params.require(:recipe).permit(:title, :instructions, :prep_time, :cook_time, :image, :remove_image, :is_private, :calories, tag_ids: [])
  end

  def process_ingredients_for(recipe)
    ingredient_data = params.dig(:recipe, :recipe_ingredients_data) || []

    recipe.recipe_ingredients.destroy_all

    ingredient_data.each do |data|
      next if data[:ingredient_id].blank?

      RecipeIngredient.create!(
        recipe: recipe,
        ingredient_id: data[:ingredient_id],
        amount: data[:amount],
        unit: data[:unit]
      )
    end
  end
end

# git commmit -m 'JavaScript fix, JS duplikácia, Transaction + Rescue, UX'

