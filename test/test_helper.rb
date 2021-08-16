ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # def sign_in(user:, password:)
  #   post user_session_path \
  #     "user[email]"    => user.email,
  #     "user[password]" => password
  #   # post "/users/sign_in" #user_session_path, params: { email: user.email, password: password }
  # end

  def sign_in(user:, password:)
    post user_session_path \
      'user[email]'    => user.email,
      'user[password]' => password
  end
  
  # Add more helper methods to be used by all tests here...
end
