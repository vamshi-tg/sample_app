require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  valid_payload = {params: { user: { name:  "vamshi",
                    email: "user@example.com",
                    password: "a12345",
                    password_confirmation: "a12345" } } }

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
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    # assert_template 'users/show'
    assert_template 'users/show'
    assert is_logged_in?
  end
  
end
