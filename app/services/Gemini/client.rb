require "net/http"
require "uri"
require "json"

module Gemini
  class Client
    SCHEMAS = {
      calorie_estimation: {
        type: "object",
        properties: {
          calories_per_100g: { type: "number" }
        },
        required: ["calories_per_100g"]
      }
    }.freeze

    ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent"

    def self.generate(prompt)
      uri = URI(ENDPOINT)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["x-goog-api-key"] = ENV.fetch("GEMINI_API_KEY")

      request.body = {
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: {
          responseMimeType: "application/json",
          responseJsonSchema: SCHEMAS[:calorie_estimation]
        }
      }.to_json

      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end