# Required Libraries
require "http"
require "json"
require "dotenv/load"

# Program Heading
puts
puts "=" * 40
puts "Will you need an umbrella today?"
puts "=" * 40
puts 

# Hidden Variables
gmaps_api_key = ENV.fetch("GMAPS_KEY")
pirate_weather_api_key = ENV.fetch("PIRATE_WEATHER_KEY")

# Get User's Location
puts "Where are you located?"
puts
user_location = gets.chomp
puts
puts "Checking the weather in " + user_location + "..."
puts

# Generate URL for Querying Google Maps API 
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + gmaps_api_key

# Query Google Maps API w/ User Input and Parse Response
raw_gmaps_response = HTTP.get(gmaps_url)
parsed_gmaps_response = JSON.parse(raw_gmaps_response.to_s)

# Retrieve Latitude and Longitude 
location_hash = parsed_gmaps_response.fetch("results").at(0).fetch("geometry").fetch("location")
latitude = location_hash.fetch("lat")
longitude = location_hash.fetch("lng")

# Generate URL for Querying Pirate Weather API
pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_api_key + "/#{latitude},#{longitude}" 

# Query Pirate Weather API
raw_pirate_response = HTTP.get(pirate_weather_url)
parsed_pirate_response = JSON.parse(raw_pirate_response.to_s)

# Retrieve Current Temperature & Next Hour Summary
current_temp = parsed_pirate_response.fetch("currently").fetch("temperature")
weather_summary = parsed_pirate_response.fetch("hourly").fetch("summary")

puts "It is currently #{current_temp}°F"
puts "Next hour: " + weather_summary
puts

# Create Hourly Forecast Array
hourly_forecast_array = parsed_pirate_response.fetch("hourly").fetch("data")
rain_chance = 0

# Loop Through Hourly Forecast Array
hourly_forecast_array.each_with_index do |hour, index|
  
  # Stop After 12 Times
  break if index >=12 

  # Check If the Rain Chance is Greater Than 10%
  if hour.fetch("precipProbability") > 0.1 
    rain_chance = rain_chance + 1
  end

  puts "In #{index + 1} hours, there is a #{(hour.fetch("precipProbability") * 100).round}% chance of precipitation."    

end

if rain_chance > 0
  puts
  puts "We recommend bringing an umbrella today!"
  puts
end
