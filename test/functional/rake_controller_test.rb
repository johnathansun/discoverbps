require 'test_helper'

class RakeControllerTest < ActionController::TestCase
  test "should get db:migrate" do
    get :db:migrate
    assert_response :success
  end

end
