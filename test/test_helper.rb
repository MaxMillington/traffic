ENV["RACK_ENV"] ||= "test"


require 'bundler'
Bundler.require

require File.expand_path("../../config/environment", __FILE__)
require 'minitest/autorun'
require 'minitest/pride'
require 'capybara'
require 'tilt/erb'

Capybara.app = TrafficSpy::Server
Capybara.save_and_open_page_path = "/tmp"
include Capybara::DSL

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation, {except: %w[public.schema_migrations]}


class Minitest::Test

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

end




class ControllerTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TrafficSpy::Server
  end

end
