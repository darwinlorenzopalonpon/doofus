class RecipeGeneratorService
  require "net/http"
  require "uri"
  require "json"
  require "concurrent"

  # OpenAI API settings
  OPENAI_API_KEY = ENV["OPENAI_API_KEY"]
  OPENAI_API_ENDPOINT = "https://api.openai.com/v1/chat/completions"
  OPENAI_MODEL = ENV["OPENAI_MODEL"] || "gpt-4.1-nano"

  # Recipe Variations Configuration
  RECIPE_VARIATIONS = [
    {
      type: "traditional",
      name: "Traditional",
      instruction: "Focus on classic, time-tested cooking methods and traditional flavor profiles."
    },
    {
      type: "quick",
      name: "Quick",
      instruction: "Prioritize speed and efficiency, using shortcuts and quick-cooking techniques."
    },
    {
      type: "creative",
      name: "Creative",
      instruction: "Explore unique flavor combinations and innovative cooking techniques."
    }
  ].freeze

  def self.generate_recipe(params)
    new.generate_recipe(params)
  end

  def self.generate_multiple_recipes(params)
    new.generate_multiple_recipes(params)
  end

  def generate_recipe(params)
    prompt = build_prompt(params)
    call_openai_api(prompt)
  rescue StandardError => e
    Rails.logger.error("Recipe generation failed: #{e.message}")
    "Sorry, we couldn't generate a recipe at this time. Please try again later."
  end

  def generate_multiple_recipes(params)
    recipe_variations = create_recipe_variations(params)

    # Use concurrent execution with Promises API
    promises = recipe_variations.map.with_index do |variation, index|
      Concurrent::Promises.future do
        begin
          prompt = build_prompt(variation)
          call_openai_api(prompt)
        rescue StandardError => e
          Rails.logger.error("Recipe #{index + 1} generation failed: #{e.message}")
          "Sorry, we couldn't generate recipe #{index + 1} at this time."
        end
      end
    end

    recipes = promises.map(&:value!)

    {
      recipes: recipes,
      variations: recipe_variations.map { |v| v[:variation_config][:type] }
    }
  rescue StandardError => e
    Rails.logger.error("Multiple recipe generation failed: #{e.message}")

    # Fallback to single recipe
    {
      recipes: [generate_recipe(params)],
      variations: ["standard"],
      fallback: true
    }
  end

  private

  def create_recipe_variations(params)
    RECIPE_VARIATIONS.map.with_index do |variation_config, index|
      params.merge(
        variation_config: variation_config,
        recipe_number: index + 1
      )
    end
  end

  def build_prompt(params)
    variation_instruction = params[:variation_config]&.dig(:instruction) || ""

    <<~PROMPT
      You are a professional chef creating recipe #{params[:recipe_number] || 1}. #{variation_instruction}

      REQUIREMENTS:
      - Type: #{params[:meal_type]} for #{params[:servings]} servings
      - Time: #{params[:time_available]}
      - Must use: #{params[:must_use_ingredients]} (prominently featured)
      - Available: #{params[:available_ingredients]}
      - Equipment: #{params[:cooking_equipment]}

      FORMAT (be concise but complete):
      # [Recipe Name]

      ## Description
      [1-2 sentences]

      ## Ingredients (#{params[:servings]} servings)
      [List with precise quantities]

      ## Instructions
      [Numbered steps]

      ## Time & Notes
      Prep: X min | Cook: Y min | Total: Z min
      [Brief chef's notes]

      CONSTRAINTS:
      - Scale ingredients precisely for #{params[:servings]} servings
      - Use must-use ingredients as main components
      - Stay within #{params[:time_available]} timeframe
      - #{variation_instruction}
    PROMPT
  end

  def call_openai_api(prompt)
    unless OPENAI_API_KEY
      raise "OpenAI API key not configured. Please set OPENAI_API_KEY in your environment variables."
    end

    uri = URI.parse(OPENAI_API_ENDPOINT)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{OPENAI_API_KEY}"

    request.body = {
      model: OPENAI_MODEL,
      messages: [
        { role: "system", content: "You are a professional chef who creates concise, precise recipes." },
        { role: "user", content: prompt }
      ],
      temperature: 0.8,
      max_tokens: 1500
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request(request)

    if response.code.to_i == 200
      result = JSON.parse(response.body)
      result["choices"][0]["message"]["content"]
    else
      raise "API request failed with status #{response.code}: #{response.body}"
    end
  end
end
