class MealsController < ApplicationController
  def index
    redirect_to meals_new_path
  end

  def new
  end

  def create
    @meal_data = {
      meal_type: params[:meal_type],
      servings: params[:servings],
      time_available: params[:time_available],
      available_ingredients: params[:available_ingredients],
      must_use_ingredients: params[:must_use_ingredients],
      cooking_equipment: params[:cooking_equipment] || []
    }

    # Always generate multiple recipes (3 variations)
    @recipe_data = RecipeGeneratorService.generate_multiple_recipes(@meal_data)
    @multiple_recipes = true

    render :result
  end

  def result
    unless @recipe_data.present?
      redirect_to meals_new_path, alert: "Please enter meal details to generate recipes"
    end
  end
end
