require 'test_helper'

class SchoolsControllerTest < ActionDispatch::IntegrationTest#ActionController::TestCase
  setup do
    @password = "password"
    @confirmed_user = User.create(email: "#{rand(50000)}@example.com", 
                                  password: @password )
    # @unconfirmed_user = User.create(email: "#{rand(50000)}@example.com", 
    #                                 password: @password )

    @school = schools(:one)
  end

  test "should get index" do
    sign_in(user: @confirmed_user, password: @password)
    get schools_path
    assert_response :success
  end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  # test "should create school" do
  #   assert_difference('School.count') do
  #     post :create, school: {  }
  #   end

  #   assert_redirected_to school_path(assigns(:school))
  # end

#   test "should show school" do
#     get :show, id: @school
#     assert_response :success
#   end

#   test "should get edit" do
#     get :edit, id: @school
#     assert_response :success
#   end

#   test "should update school" do
#     put :update, id: @school, school: {  }
#     assert_redirected_to school_path(assigns(:school))
#   end

#   test "should destroy school" do
#     assert_difference('School.count', -1) do
#       delete :destroy, id: @school
#     end

#     assert_redirected_to schools_path
#   end
end
