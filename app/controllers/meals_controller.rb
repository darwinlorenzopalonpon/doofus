class MealsController < ApplicationController
  def index
    # Landing page for the meal prep feature
    redirect_to meals_new_path
  end

  # New single-form approach
  def new
    # Display the single combined form
  end

  def create
    # Process all form data at once
    @meal_data = {
      # Step 1 data
      meal_type: params[:meal_type],
      servings: params[:servings],
      time_available: params[:time_available],

      # Step 2 data
      available_ingredients: params[:available_ingredients],
      must_use_ingredients: params[:must_use_ingredients],
      cooking_equipment: params[:cooking_equipment] || []
    }

    # Generate recipe using LLM
    @recipe = RecipeGeneratorService.generate_recipe(@meal_data)

    render :result
  end

  def result
    # This action is now only used when accessed directly (e.g. from a saved link)
    # The create action will render this template after processing the form
    unless @recipe.present?
      redirect_to meals_new_path, alert: "Please enter meal details to generate a recipe"
    end
  end
end
