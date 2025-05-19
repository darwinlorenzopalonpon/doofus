# Setting Up Your OpenAI API Key

This application uses OpenAI's API for generating recipes. Follow these steps to set up your API key:

## Getting an API Key

1. **Create an OpenAI account**:
   - Go to https://platform.openai.com/signup
   - Complete the registration process
   - Set up billing information

2. **Generate an API key**:
   - Once logged in, navigate to https://platform.openai.com/api-keys
   - Click "Create new secret key"
   - Give your key a name (e.g., "Doofus Recipe Generator")
   - Copy the key immediately (you won't be able to see it again)

## Setting Up Your Development Environment

1. **Create a .env file in the project root**:
   ```
   # OpenAI API key for recipe generation
   OPENAI_API_KEY=your_api_key_here
   OPENAI_MODEL=gpt-3.5-turbo
   ```

2. **Replace `your_api_key_here` with your actual API key**

3. **Install the required gems**:
   ```bash
   bundle install
   ```

4. **Restart your Rails server** to load the new environment variables:
   ```bash
   rails server
   ```

## Available Models

You can change the model by updating the `OPENAI_MODEL` environment variable. Recommended models:

- `gpt-3.5-turbo` - Good balance of quality and cost
- `gpt-4` - Higher quality but more expensive
- `gpt-4-turbo` - Latest model with improved capabilities

## Important Notes

- **NEVER commit your API key to the repository**
- The .env file is already in .gitignore to prevent accidental commits
- OpenAI API calls cost money based on your usage
- You might want to set a usage limit in your OpenAI account settings

## For Production Deployment

Set the environment variable through your hosting provider's dashboard:
- For Heroku: `heroku config:set OPENAI_API_KEY=your_api_key_here`
- For Railway, Render, etc.: Use their environment variable configuration 