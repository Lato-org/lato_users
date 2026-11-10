require "test_helper"

class AuthorizationTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
    @admin = Lato::User.find_by!(email: "pippo.franco@mail.com")
    @member = create_user("member@mail.com", admin: false)
  end

  test "non admin users are redirected and cannot run any action" do
    authenticate_user(@member)
    target = create_user("target@mail.com", admin: false)
    digest = target.password_digest

    get lato_users.users_path
    assert_redirected_to lato.root_path
    post lato_users.users_path, params: { user: { email: "x@mail.com", first_name: "X", last_name: "X", password: "Password1!", password_confirmation: "Password1!" } }
    assert_redirected_to lato.root_path
    patch lato_users.user_path(target), params: { user: { lato_users_admin: "1" } }
    patch lato_users.force_update_password_user_path(target)
    delete lato_users.user_path(target)
    post lato_users.invitations_path, params: { invitation: { email: "invited@mail.com" } }

    assert_nil Lato::User.find_by(email: "x@mail.com")
    assert_not target.reload.lato_users_admin
    assert_equal digest, target.password_digest
    assert Lato::User.exists?(target.id)
    assert_nil Lato::Invitation.find_by(email: "invited@mail.com")
  end

  test "non html requests from non admin users get 403" do
    authenticate_user(@member)

    get lato_users.users_path, headers: { "Accept" => "application/json" }

    assert_response :forbidden
  end

  test "admin cannot remove their own users admin permission" do
    authenticate_user(@admin)

    patch lato_users.user_path(@admin), params: { user: { lato_users_admin: "0" } }

    assert_response :unprocessable_entity
    assert @admin.reload.lato_users_admin
  end

  test "admin can demote another admin while an admin remains" do
    other = create_user("other-admin@mail.com", admin: true)
    authenticate_user(@admin)

    patch lato_users.user_path(other), params: { user: { lato_users_admin: "0" } }

    assert_redirected_to lato_users.users_path
    assert_not other.reload.lato_users_admin
  end

  test "admin cannot delete themselves" do
    authenticate_user(@admin)

    delete lato_users.user_path(@admin)

    assert_redirected_to lato_users.users_path
    assert Lato::User.exists?(@admin.id)
  end

  test "password is ignored on update" do
    authenticate_user(@admin)
    digest = @member.password_digest

    patch lato_users.user_path(@member), params: { user: { first_name: "Changed", password: "Another1!", password_confirmation: "Another1!" } }

    assert_equal "Changed", @member.reload.first_name
    assert_equal digest, @member.password_digest
  end

  test "create and update set a notice and a failed create is unprocessable" do
    authenticate_user(@admin)

    post lato_users.users_path, params: { user: { email: "new@mail.com", first_name: "New", last_name: "User", password: "Password1!", password_confirmation: "Password1!" } }
    assert_redirected_to lato_users.users_path
    assert_equal I18n.t("lato_users.user_created"), flash[:notice]

    post lato_users.users_path, params: { user: { email: "", first_name: "", last_name: "" } }
    assert_response :unprocessable_entity
  end

  test "force update password renders the password once without flash and revokes sessions" do
    authenticate_user(@admin)
    @member.lato_session_records.create!(token_digest: "digest", expires_at: 1.day.from_now)

    patch lato_users.force_update_password_user_path(@member)

    assert_response :success
    assert_empty flash.to_h
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal 0, @member.lato_session_records.count
    assert_no_match(/password_digest/, response.body)
    assert_select "input#generated_password[readonly]" do |inputs|
      assert @member.reload.authenticate(inputs.first["value"])
    end
  end

  test "changing another user's email revokes their sessions" do
    authenticate_user(@admin)
    @member.lato_session_records.create!(token_digest: "digest", expires_at: 1.day.from_now)

    patch lato_users.user_path(@member), params: { user: { email: "renamed@mail.com" } }

    assert_equal 0, @member.lato_session_records.count
  end

  test "admin pages render" do
    authenticate_user(@admin)

    [lato_users.users_path, lato_users.new_user_path, lato_users.user_path(@member), lato_users.invitations_path, lato_users.new_invitation_path].each do |path|
      get path
      assert_response :success, path
    end
    get lato_users.new_user_path
    assert_select "button[type=button][data-action*='generatePassword']"
  end

  test "permission checkbox label points to the checkbox id" do
    authenticate_user(@admin)

    get lato_users.edit_user_path(@member, redirect_to: lato_users.users_path)

    checkbox = css_select("input[type=checkbox][name='user[lato_users_admin]']").first
    assert_select "label[for='#{checkbox["id"]}']", text: "Users admin"
  end

  test "destroying an accepted invitation does not claim success" do
    authenticate_user(@admin)
    invitation = lato_invitations(:invitation)
    invitation.update_columns(accepted_at: Time.current)

    delete lato_users.invitation_path(invitation)

    assert_redirected_to lato_users.invitations_path
    assert_nil flash[:notice]
    assert_equal I18n.t("lato_users.cannot_delete_accepted_invitation"), flash[:alert]
    assert Lato::Invitation.exists?(invitation.id)
  end

  test "invitation resend reports delivery success and failure" do
    authenticate_user(@admin)
    invitation = lato_invitations(:invitation)

    post lato_users.resend_invitation_path(invitation)
    assert_equal I18n.t("lato_users.invitation_resent"), flash[:notice]

    original = Lato::InvitationMailer.method(:invite_mail)
    Lato::InvitationMailer.define_singleton_method(:invite_mail) { |_id| raise "smtp down" }
    begin
      post lato_users.resend_invitation_path(invitation)
    ensure
      Lato::InvitationMailer.define_singleton_method(:invite_mail, original)
    end
    assert_equal I18n.t("lato_users.invitation_email_failed"), flash[:alert]
  end

  private

  def create_user(email, admin:)
    Lato::User.create!(
      first_name: "Test", last_name: "User", email: email,
      password: "Password1!", password_confirmation: "Password1!",
      accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version,
      accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version,
      lato_users_admin: admin
    )
  end
end
