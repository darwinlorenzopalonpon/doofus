namespace :openai do
  desc "List available OpenAI models"
  task list_models: :environment do
    require "net/http"
    require "uri"
    require "json"

    # Get API key from environment
    api_key = ENV["OPENAI_API_KEY"]

    if api_key.nil? || api_key.empty?
      puts "ERROR: OPENAI_API_KEY environment variable is not set."
      puts "Please set it in your .env file and try again."
      exit 1
    end

    # Set up the request
    uri = URI.parse("https://api.openai.com/v1/models")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{api_key}"

    # Send the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    begin
      response = http.request(request)

      if response.code.to_i == 200
        models = JSON.parse(response.body)

        # Filter and sort models
        gpt_models = models["data"].select { |model| model["id"].include?("gpt") }
        gpt_models = gpt_models.sort_by { |model| model["id"] }

        puts "\n=== Available GPT Models ===\n\n"
        gpt_models.each do |model|
          puts "- #{model['id']}"
        end

        puts "\n=== Other Available Models ===\n\n"
        other_models = models["data"].reject { |model| model["id"].include?("gpt") }
        other_models = other_models.sort_by { |model| model["id"] }

        other_models.each do |model|
          puts "- #{model['id']}"
        end

        puts "\n=== Recommended Models for Recipe Generation ===\n\n"
        puts "- gpt-3.5-turbo (Use this if you don't have access to GPT-4)"
        puts "- gpt-4-turbo-preview (Best quality if available)"
        puts "- gpt-3.5-turbo-instruct (Alternative option)"
      else
        puts "Error: #{response.code} - #{response.body}"
      end
    rescue => e
      puts "Exception: #{e.message}"
    end
  end
end
