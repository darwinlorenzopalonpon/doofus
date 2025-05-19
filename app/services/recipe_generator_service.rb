class RecipeGeneratorService
  require 'net/http'
  require 'uri'
  require 'json'

  # OpenAI API settings
  OPENAI_API_KEY = ENV['OPENAI_API_KEY']
  OPENAI_API_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
  OPENAI_MODEL = ENV['OPENAI_MODEL'] || 'gpt-4.1-nano'

  def self.generate_recipe(params)
    new.generate_recipe(params)
  end

  def generate_recipe(params)
    prompt = build_prompt(params)
    response = call_openai_api(prompt)

    # Return the LLM response text
    response
  rescue StandardError => e
    # Log the error
    Rails.logger.error("Recipe generation failed: #{e.message}")

    # Return an error message
    "Sorry, we couldn't generate a recipe at this time. Please try again later."
  end

  private

  def build_prompt(params)
    <<~PROMPT
      You are a professional chef who specializes in recipe development. Create a complete recipe based on the following requirements:

      MEAL DETAILS:
      - Type: #{params[:meal_type]}
      - IMPORTANT: This recipe MUST be for exactly #{params[:servings]} servings. Scale all ingredients to match this serving count precisely.
      - Preparation time: #{params[:time_available]} (This is the amount of time the user has to prepare the entire meal. Try to keep the recipe within this time frame.)

      INGREDIENTS:
      - Available ingredients: #{params[:available_ingredients]} (These are ingredients the user has on hand. You can use some, all, or add reasonable additional ingredients.)
      - Must-use ingredients: #{params[:must_use_ingredients]} (These MUST be included in the recipe in significant quantities, not just as garnish or optional.)

      EQUIPMENT:
      - Available cooking tools: #{params[:cooking_equipment]} (These are the tools the user has available to them. You can use some, all, or add reasonable additional tools.)

      IMPORTANT RULES:
      1. All ingredient quantities MUST be precise and scaled correctly for exactly #{params[:servings]} servings.
      2. Include specific measurements (e.g., "2 cups flour" not just "flour").
      3. The must-use ingredients should be central to the recipe, not just minor additions.
      4. Ensure cooking times are appropriate for the available preparation time.
      5. Use measurements that make sense for home cooking (standard cups, tablespoons, teaspoons, ounces, pounds).
      6. The result does not have to be a single dish. It can be a multi-course meal.

      Format your response as a beautiful, readable recipe with the following sections:

      # [RECIPE NAME]

      ## Description
      [Brief description of the dish, 1-2 sentences]

      ## Ingredients (for #{params[:servings]} servings)
      - [Precise quantity] [Ingredient 1]
      - [Precise quantity] [Ingredient 2]
      [...]

      ## Instructions
      1. [Step 1]
      2. [Step 2]
      [...]

      ## Time
      - Prep: [x minutes]
      - Cook: [y minutes]
      - Total: [z minutes]

      ## Chef's Notes
      [Brief notes about the recipe, including how the must-use ingredients were incorporated, scaling tips, and any helpful suggestions]
    PROMPT
  end

  def call_openai_api(prompt)
    # Check if API key is available
    unless OPENAI_API_KEY
      raise "OpenAI API key not configured. Please set OPENAI_API_KEY in your environment variables."
    end

    # Create the request
    uri = URI.parse(OPENAI_API_ENDPOINT)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = "Bearer #{OPENAI_API_KEY}"

    # Build the request body
    request.body = {
      model: OPENAI_MODEL,
      messages: [
        { role: 'system', content: 'You are a professional chef who specializes in precise recipe development.' },
        { role: 'user', content: prompt }
      ],
      temperature: 0.7,
      max_tokens: 2000
    }.to_json

    # Send the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    # Process the response
    if response.code.to_i == 200
      result = JSON.parse(response.body)
      result['choices'][0]['message']['content']
    else
      raise "API request failed with status #{response.code}: #{response.body}"
    end
  end
end
