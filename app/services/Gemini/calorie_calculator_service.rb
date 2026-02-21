module Gemini
  class CalorieCalculatorService
    def initialize(recipe)
      @recipe = recipe 
    end

    def call
      prompt = build_prompt
      
      raw_response = Gemini::Client.generate(prompt)
      text = raw_response.dig("candidates", 0, "content", "parts", 0, "text")
      
      return nil if text.nil?

      result = JSON.parse(text)
      result["calories_per_100g"]
    rescue => e
      Rails.logger.error "Gemini Calorie Error: #{e.message}"
      nil
    end

    private

    def build_prompt
      ingredients_list = @recipe.recipe_ingredients.map do |ri|
      "#{ri.amount} #{ri.unit} #{ri.ingredient.name}"
    end.join(", ")

      <<~PROMPT
        Analyze the following ingredients for a recipe:
        #{ingredients_list}

        Calculate the total estimated calories per 100g of the final dish.
        Return ONLY the number in JSON format.
      PROMPT
    end
  end
end