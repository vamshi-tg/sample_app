require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Dummy", email: "dummy@gmail.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 250 + "@gmail.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email shoulb be saved in lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    test_user_1 = users(:test_user_1)
    test_user_2  = users(:test_user_2)
    assert_not test_user_1.following?(test_user_2)
    test_user_1.follow(test_user_2)
    assert test_user_1.following?(test_user_2)
    assert test_user_2.followers.include?(test_user_1)
    test_user_1.unfollow(test_user_2)
    assert_not test_user_1.following?(test_user_2)
  end

  test "feed should have the right posts" do
    test_user_1 = users(:test_user_1)
    test_user_2  = users(:test_user_2)
    test_user_3    = users(:test_user_3)
    # Posts from followed user
    test_user_3.microposts.each do |post_following|
      assert test_user_1.feed.include?(post_following)
    end
    # Posts from self
    test_user_1.microposts.each do |post_self|
      assert test_user_1.feed.include?(post_self)
    end
    # Posts from unfollowed user
    test_user_2.microposts.each do |post_unfollowed|
      assert_not test_user_1.feed.include?(post_unfollowed)
    end
  end
end
