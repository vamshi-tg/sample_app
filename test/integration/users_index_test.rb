require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:test_user_1)
    @non_admin = users(:test_user_2)
    @unactivated_user = users(:test_user_999)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "should not show non-activated users" do
    log_in_as(@admin)
    get users_path
    test_users = assigns(:users)
    test_users.total_pages.times do |page|
      get users_path(page: page+1)
      assert_select 'a[href=?]', user_path(@unactivated_user), text: @unactivated_user.name, count: 0

      # assert_not test_users_per_page.include?(@unactivated_user)
    end
    assert_template 'users/index'
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
