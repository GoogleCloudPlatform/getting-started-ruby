require "sinatra"
require "securerandom"

require_relative "pre_app"
require_relative "session_store"

enable :sessions
set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex 64 }
set :session_store, Rack::Session::FirestoreSession


set :colors, ["red", "blue", "green", "yellow", "pink"]
set :greetings, ["Hello World", "Hallo Welt", "Ciao Mondo", "Salut le Monde", "Hola Mundo"]

get "/" do
  puts "session"
  p session
  session["greeting"] ||= settings.greetings.sample
  session["views"] ||= 0
  session["views"] += 1
  "<h1>#{session['views']} views for #{session['greeting']}</h1>"
end
