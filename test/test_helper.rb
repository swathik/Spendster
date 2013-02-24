ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl'
require_relative 'factories'

class ActiveSupport::TestCase
  include Devise::TestHelpers
  
  # Add more helper methods to be used by all tests here...

  # Seed the database before each test case.
  # setup :setup_mongodb
  # 
  # def setup_mongodb
  #   load File.join(Rails.root, 'Rakefile') unless defined?(Rake)
  #   Rake::Task['db:seed'].execute
  # end
  
  # Drop all columns after each test case.
  # teardown :clean_mongodb
  # def clean_mongodb
  #    Mongoid.default_session.collections.each do |collection|
  #      unless collection.name =~ /^system\./
  #        collection.drop
  #      end
  #   end
  # end  

end

class ActionController::TestCase
  include Devise::TestHelpers
  
end
