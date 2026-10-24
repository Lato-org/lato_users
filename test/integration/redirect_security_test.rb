require "test_helper"

class RedirectSecurityTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @user = Lato::User.find_by!(email: "pippo.franco@mail.com")
    authenticate_user
  end

  test "updating a user rejects external redirect targets" do
    patch lato_users.user_path(@user), params: {
      user: { first_name: "Updated" }, redirect_to: "https://attacker.example/phishing"
    }

    assert_redirected_to lato_users.users_path
    assert_equal "Updated", @user.reload.first_name
  end

  test "updating a user accepts local redirect targets" do
    target = lato_users.user_path(@user)
    patch lato_users.user_path(@user), params: {
      user: { first_name: "Updated" }, redirect_to: target
    }

    assert_redirected_to target
    assert_equal "Updated", @user.reload.first_name
  end

  test "updating a user rejects protocol relative redirect targets" do
    patch lato_users.user_path(@user), params: {
      user: { first_name: "Updated" }, redirect_to: "//attacker.example/phishing"
    }

    assert_redirected_to lato_users.users_path
  end
end
