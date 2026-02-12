=begin
class CalorieCalculatorService
  def initialize(recipe)
    Ethon.logger = Logger.new(nil) # Toto vypne ETHON logy
    @recipe = recipe
    @client = Gemini.new(
      credentials: { 
        service: 'generative-language-api', 
        api_key: ENV['GEMINI_API_KEY'] 
      },
      options: {
        model: 'gemini-2.0-flash'
      }
      )
  end

  def call
    gemini_data = @recipe.recipe_ingredients.map do |ri|
      {
        name: ri.ingredient.name,
        amount: ri.amount,
        unit: ri.unit.to_s
      }
    end
    return nil if gemini_data.empty?

    prompt = "Calculate calories for this list of ingredients: #{gemini_data.to_json}. " \
             "Based on these amounts, calculate what the caloric value would be for 100 grams of this finished dish. " \
             "Return only the number (integer). Nothing else."

    puts "--- ODOSIELAM DO AI: #{prompt} ---"

    begin
    gemini_result = @client.generate_content(
      {
        contents: [
          { 
            role: 'user', 
            parts: [
              { text: prompt }
            ]
          }
        ]
      }
      )

    calories_string = gemini_result.dig("candidates", 0, "content", "parts", 0, "text")
    puts "DEBUG: Gemini returned: #{calories_string}"

    return nil if calories_string.blank?

    number = calories_string[/\d+/]
    number ? number.to_i : nil
    rescue => e
      clean_error = e.message.gsub(ENV['GEMINI_API_KEY'], "[FILTERED]")
      Rails.logger.error "Gemini API Error: #{clean_error}"
      nil
    end
  end
end
=end

class CalorieCalculatorService
  def initialize(recipe)
    Ethon.logger = Logger.new(nil) # vypne Ethon logy
    @recipe = recipe

    @client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GEMINI_API_KEY']
      }
    )
  end

  def call
    # pripravíme dáta o ingredienciách
    gemini_data = @recipe.recipe_ingredients.map do |ri|
      {
        name: ri.ingredient.name,
        amount: ri.amount,
        unit: ri.unit.to_s
      }
    end

    return nil if gemini_data.empty?

    prompt = <<~PROMPT
      Calculate calories for this list of ingredients: #{gemini_data.to_json}.
      Based on these amounts, calculate the caloric value per 100 grams of the finished dish.
      Return only the number (integer). Nothing else.
    PROMPT

    puts "--- ODOSIELAM DO AI: #{prompt.strip} ---"

    begin
      gemini_result = @client.generate_content(
        {
          contents: [
            {
              role: 'user',
              parts: [{ text: prompt.strip }]
            }
          ]
        },
        model: 'gemini-flash-latest', # <-- funkčný model
        server_sent_events: false
      )

      # získame výsledok
      calories_string = gemini_result.dig("candidates", 0, "content", "parts", 0, "text")
      puts "DEBUG: Gemini returned: #{calories_string}"

      return nil if calories_string.blank?

      # extrahujeme číslo
      number = calories_string[/\d+/]
      number ? number.to_i : nil

    rescue => e
      clean_error = e.message.gsub(ENV['GEMINI_API_KEY'], "[FILTERED]")
      Rails.logger.error "Gemini API Error: #{clean_error}"
      nil
    end
  end
end
