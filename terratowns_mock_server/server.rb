require 'sinatra'
require 'json'
require 'pry'
require 'active_model'

# we will mock having a state or database for this development server
# by setting a global variable. You would never use a global variable in production server.

$home = {}

# this is ruby class that includes validations from Activerecord.
# this will represent our home resources as a ruby object.
class Home
  # ActiveModel is part of Ruby on Rails.
  # it is used as an ORM. It has module within ActiveModelthat provides validations.
  # The production Terratowns server is rails and uses very similar and in most cases identical validation
  # https://guides.rubyonrails.org/active_model_basics.html

  include ActiveModel::Validations

  # create some virtual attributes to store on this object
  # This will set a getter and setter

  attr_accessor :town, :name, :description, :domain_name, :content_version

  # https://guides.rubyonrails.org/active_model_basics.html#validations
  # https://guides.rubyonrails.org/active_record_validations.html#inclusion

 
  validates :town, presence: true, inclusion: { in: ['melomaniac-mansion', 'cooker-cove', 'video-valley', 'the-nomad-pad', 'gamers-grotto']}
   # visible to all users
  validates :name, presence: true
  validates :description, presence: true
  
  # we want to lock this down to only be from cloudfront
  validates :domain_name, 
    format: { with: /\.cloudfront\.net\z/, message: "domain must be from .cloudfront.net" }
    # uniqueness: true, 
# content version has to be an integer
# we will make sure it an incredemental version in the controller
  validates :content_version, numericality: { only_integer: true }
end

# we are extending a class from Sinatra::Base to turn this generic class to utilize the sinatra web framework

class TerraTownsMockServer < Sinatra::Base

  def error code, message
    halt code, {'Content-Type' => 'application/json'}, {err: message}.to_json
  end

  def error_json json
    halt code, {'Content-Type' => 'application/json'}, json
  end

  def ensure_correct_headings
    unless request.env["CONTENT_TYPE"] == "application/json"
      error 415, "expected Content_type header to be application/json"
    end

    unless request.env["HTTP_ACCEPT"] == "application/json"
      error 406, "expected Accept header to be application/json"
    end
  end

  # return a hardcoded access token
  def x_access_code
    return '9b49b3fb-b8e9-483c-b703-97ba88eef8e0'
  end

  def x_user_uuid
    return 'e328f4ab-b99f-421c-84c9-4ccea042c7d1'
  end

  def find_user_by_bearer_token
    # https://swagger.io/docs/specification/authentication/bearer-authentication/
    auth_header = request.env["HTTP_AUTHORIZATION"]
    
    # check if the Authorization header exists
    if auth_header.nil? || !auth_header.start_with?("Bearer ")
      error 401, "a1000 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    # check if the token matches with the one in our database, code is token or access_code
    code = auth_header.split("Bearer ")[1]
    if code != x_access_code
      error 401, "a1001 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    # was there a user_uuid in the message body payload json?
    if params['user_uuid'].nil?
      error 401, "a1002 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    unless code == x_access_code && params['user_uuid'] == x_user_uuid
      error 401, "a1003 Failed to authenicate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end
  end

  #https://sematext.com/glossary/http-requests/#:~:text=An%20HTTP%20request%20is%20made%20out%20of%20three%20components,line%2C%20headers%20and%20message%20body. 
  # CREATE
  post '/api/u/:user_uuid/homes' do
    ensure_correct_headings()
    find_user_by_bearer_token()
    puts "# create - POST /api/homes"

  # a begin/rescume is a try/catch
    begin
      # Sinatra doesn't automatically part json bodies as params like rails, so we need to manually part it.
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 422, "Malformed JSON"
    end

    # assign payload data
    name = payload["name"]
    description = payload["description"]
    domain_name = payload["domain_name"]
    content_version = payload["content_version"]
    town = payload["town"]

    # print them out to console for this endpoint
    puts "name #{name}"
    puts "description #{description}"
    puts "domain_name #{domain_name}"
    # puts "content_version #{content_version}"
    puts "town #{town}"
    puts "content_version #{content_version}"

    # create new home model and set its attributes
    home = Home.new
    home.name = name
    home.description = description
    home.domain_name = domain_name
    home.town = town
    home.content_version = content_version
    
    # Run our validation checks
    unless home.valid?
      # return errors message back to json
      error 422, home.errors.messages.to_json
    end

    # generating a uuid randomly
    uuid = SecureRandom.uuid
    puts "uuid #{uuid}"
    # mock our data to our mock data base which just a global variable
    $home = {
      uuid: uuid,
      name: name,
      town: town,
      description: description,
      domain_name: domain_name,
      content_version: content_version
    }

    # return uuid
    return { uuid: uuid }.to_json
  end

  # READ
  get '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# read - GET /api/homes/:uuid"

    # checks for house limit

    content_type :json
    # check uuid for the home match the one in our database
    if params[:uuid] == $home[:uuid]
      return $home.to_json
    else
      error 404, "failed to find home with provided uuid and bearer token"
    end
  end

  # UPDATE
  put '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# update - PUT /api/homes/:uuid"
    begin
      # Parse JSON payload from the request body
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      halt 422, "Malformed JSON"
    end

    # Validate payload data
    name = payload["name"]
    description = payload["description"]
    domain_name = payload["domain_name"]
    content_version = payload["content_version"]

    unless params[:uuid] == $home[:uuid]
      error 404, "failed to find home with provided uuid and bearer token"
    end

    home = Home.new
    home.town = $home[:town]
    home.domain_name = $home[:domain_name]
    home.name = name
    home.description = description
    # home.domain_name = domain_name
    home.content_version = content_version

    unless home.valid?
      error 422, home.errors.messages.to_json
    end

    return { uuid: params[:uuid] }.to_json
  end

  # DELETE
  delete '/api/u/:user_uuid/homes/:uuid' do
    ensure_correct_headings
    find_user_by_bearer_token
    puts "# delete - DELETE /api/homes/:uuid"
    content_type :json

    if params[:uuid] != $home[:uuid]
      error 404, "failed to find home with provided uuid and bearer token"
    end
    # delete from mock database
    uuid = $home[:uuid]
    $home = {}
    { uuid: uuid }.to_json
  end
end

# This is what will run the server
TerraTownsMockServer.run!