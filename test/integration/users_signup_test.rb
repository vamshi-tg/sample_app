require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  valid_payload = {params: { user: { name:  "vamshi",
                    email: "user@gmail.com",
                    password: "p12345",
                    password_confirmation: "p12345" } } }

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      invalid_payload = {params: { user: { name:  "vamshi",
                                          email: "user@invalid",
                                          password: "p1234",
                                          password_confirmation: "p1234" } } }
      post users_path, invalid_payload 

      ERROR_MSG_REGEX = /The form contains 2 errors\..*Email is invalid.*Password is too short \(minimum is 6 characters\)/m
      assert_select "div#error_explanation", ERROR_MSG_REGEX
    end
    assert_template 'users/new'
  end

  test "check form url" do
    get signup_path
    assert_select "form[action=?]", signup_path
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, valid_payload
    end
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
  
end
