class RecipesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy, :save_to_cookbook]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  
  # GET /recipes
  def index
    @recipes = Recipe.where(is_private: false, parent_id: nil)
    
    if user_signed_in? 
      @recipes = @recipes.or(Recipe.where(user: current_user, parent_id: nil))
    end
    
    @recipes = apply_filters(@recipes)
  end

  def my_recipes
    @recipes = current_user.recipes.where(parent_id: nil).or(current_user.recipes.where(edited_by_copyist: true))

    @recipes = apply_filters(@recipes)
  end

  def save_to_cookbook
    if @recipe.user == current_user
      redirect_to @recipe, alert: "This is already your recipe!"
      return
    end

    @new_recipe = @recipe.duplicate_for(current_user)

    if @new_recipe.save
      redirect_to @new_recipe, notice: "Recipe was successfully copied to your cookbook."
    else
      redirect_to @recipe, alert: "Failed to copy recipe."
    end
  end

  def cookbook
    @recipes = current_user.recipes.where.not(parent_id: nil).where(edited_by_copyist: false)

    @recipes = apply_filters(@recipes)

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
      @recipe = current_user.recipes.build(recipe_params.except(:recipe_ingredients_data))
      process_ingredients_for(@recipe)
      
      if @recipe.valid?
        calculate_calories if @recipe.calories.blank?
        @recipe.save!

        redirect_to @recipe, notice: "Recipe was successfully created."
      else
        raise ActiveRecord::RecordInvalid.new(@recipe)
      end
    end

  rescue ActiveRecord::RecordInvalid
    handle_recipe_error(ingredient_data)
  end

# PATCH/PUT /recipes/1
  def update
    ingredient_data = params.dig(:recipe, :recipe_ingredients_data) || []

    Recipe.transaction do
      @recipe.edited_by_copyist = true if @recipe.parent_id
      @recipe.assign_attributes(recipe_params.except(:recipe_ingredients_data))
      process_ingredients_for(@recipe)

      if @recipe.valid?
        @recipe.image.purge if params[:recipe][:remove_image] == '1'
        calculate_calories if params[:recipe][:recalculate_calories] == '1'
        
        @recipe.save!
        
        redirect_to @recipe, notice: "Recipe was successfully updated.", status: :see_other
      else
        raise ActiveRecord::RecordInvalid.new(@recipe)
      end        
    end

  rescue ActiveRecord::RecordInvalid
    handle_recipe_error(ingredient_data)
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
    params.require(:recipe).permit(
      :title, :instructions, :prep_time, :cook_time, :image, :remove_image, :is_private, :calories, :recalculate_calories, tag_ids: [], 
      recipe_ingredients_data: [:id, :ingredient_id, :amount, :unit, :_destroy]
      )
  end

  def process_ingredients_for(recipe)
    ingredient_data = params.dig(:recipe, :recipe_ingredients_data) || []

    recipe.recipe_ingredients.destroy_all if recipe.persisted?

    ingredient_data.each do |data|
      is_completely_empty = data[:ingredient_id].blank? && data[:amount].blank? && data[:unit].blank?
      
      next if is_completely_empty || data[:_destroy] == "1"

      recipe.recipe_ingredients.build(
        ingredient_id: data[:ingredient_id],
        amount: data[:amount],
        unit: data[:unit]
      )
    end
  end

  def apply_filters(scope)
    
    if params[:query].present?
      scope = scope.where("title LIKE ?", "%#{params[:query]}%")
    end

    if params[:tag_ids].present?
      selected_ids = params[:tag_ids].compact_blank
      
      if selected_ids.any?
        tag_count = selected_ids.size

        scope = scope.joins(:tags)
                          .where(tags: { id: selected_ids })
                          .group('recipes.id')
                          .having('COUNT(tags.id) = ?', tag_count)
      end
    end

    scope
  end

  def calculate_calories
    calculated_calories = CalorieCalculatorService.new(@recipe).call
    @recipe.calories = calculated_calories if calculated_calories
  end

  def handle_recipe_error(ingredient_data)
    @recipe.recipe_ingredients.target.clear
    ingredient_data.each do |data|
      @recipe.recipe_ingredients.build(data.permit(:ingredient_id, :amount, :unit))
    end
    
    @recipe.valid?
    @recipe.errors.delete(:recipe_ingredients)

    all_ingredient_errors = []
    @recipe.recipe_ingredients.each do |ri|
      unless ri.valid?
        all_ingredient_errors << "Ingredient error: #{ri.errors.full_messages.to_sentence}"
      end
    end
    
    all_ingredient_errors.uniq.each do |msg|
      @recipe.errors.add(:base, msg)
    end
    render (action_name == 'create' ? :new : :edit), status: :unprocessable_entity
  end

end
