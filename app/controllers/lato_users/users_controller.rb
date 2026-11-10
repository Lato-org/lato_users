module LatoUsers
  class UsersController < ApplicationController
    before_action :load_available_admin_permissions

    def index
      @users = lato_index_collection(
        Lato::User.all,
        columns: %i[id email first_name last_name locale actions],
        searchable_columns: %i[email first_name last_name],
        sortable_columns: %i[id email first_name last_name],
        pagination: true,
        default_sort_by: "id|asc"
      )
    end

    def show
      @user = Lato::User.find(params[:id])
    end

    def new
      @user = Lato::User.new
    end

    # Lato::User validates the presence of the accepted privacy/terms versions, so
    # admin-created users must carry the current versions to be saved at all.
    def create
      @user = Lato::User.new(create_user_params.merge(
        accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version,
        accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version
      ))
      if permissions_valid?(@user) && @user.save
        redirect_to users_path, notice: I18n.t('lato_users.user_created')
      else
        render 'new', status: :unprocessable_entity
      end
    end

    def edit
      @user = Lato::User.find(params[:id])
    end

    def update
      @user = Lato::User.find(params[:id])
      @user.assign_attributes(update_user_params)
      if permissions_valid?(@user) && @user.save
        revoke_other_sessions(@user) if @user.saved_change_to_email?
        redirect_to(url_from(params[:redirect_to]) || users_path, notice: I18n.t('lato_users.user_updated'))
      else
        render 'edit', status: :unprocessable_entity
      end
    end

    def destroy
      @user = Lato::User.find(params[:id])

      if @user.id == @session.user_id
        redirect_to users_path, alert: I18n.t('lato_users.cannot_delete_self')
      elsif last_admin?(@user)
        redirect_to users_path, alert: I18n.t('lato_users.cannot_delete_last_admin')
      else
        @user.destroy
        redirect_to users_path, notice: I18n.t('lato_users.user_destroyed')
      end
    rescue ActiveRecord::InvalidForeignKey
      redirect_to users_path, alert: I18n.t('lato_users.cannot_delete_foreign_key')
    end

    def resend_verification_email
      @user = Lato::User.find(params[:id])
      if deliver_verification_email(@user)
        redirect_to user_path(@user), notice: I18n.t('lato_users.verification_email_sent')
      else
        redirect_to user_path(@user), alert: @user.errors.full_messages.join(', ')
      end
    end

    def manual_verify_email
      @user = Lato::User.find(params[:id])
      if @user.update(email_verified_at: Time.current)
        redirect_to user_path(@user), notice: I18n.t('lato_users.email_manually_verified')
      else
        redirect_to user_path(@user), alert: @user.errors.full_messages.join(', ')
      end
    end

    def revoke_email_verification
      @user = Lato::User.find(params[:id])
      if @user.update(email_verified_at: nil)
        redirect_to user_path(@user), notice: I18n.t('lato_users.email_verification_revoked')
      else
        redirect_to user_path(@user), alert: @user.errors.full_messages.join(', ')
      end
    end

    # The new password is rendered once in this response (no redirect), so it never
    # reaches the flash/session cookie. Saving it revokes all the user sessions.
    def force_update_password
      @user = Lato::User.find(params[:id])
      new_password = SecureRandom.hex(8)
      if @user.update(password: new_password, password_confirmation: new_password)
        @generated_password = new_password
        response.headers["Cache-Control"] = "no-store"
        render 'show'
      else
        redirect_to user_path(@user), alert: I18n.t('lato_users.password_update_failed')
      end
    end

    private

    def base_user_params
      permission_keys = @available_admin_permissions.map { |permission| permission[:name] }
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, *permission_keys)
    end

    # Passwords can only be set on create: changing one afterwards goes through force_update_password.
    def create_user_params
      base_user_params
    end

    def update_user_params
      base_user_params.except(:password, :password_confirmation)
    end

    # Discover admin permissions on Lato::User by column naming convention.
    # Each engine (lato_cms, lato_spaces, ...) adds its own column:
    #   - `lato_*_admin`      -> boolean, rendered as a checkbox
    #   - `lato_*_admin_role` -> integer enum, rendered as a select
    def load_available_admin_permissions
      @available_admin_permissions ||= Lato::User.column_names.filter_map do |name|
        if name.match?(/\Alato_.+_admin\z/)
          { name: name, type: :boolean }
        elsif name.match?(/\Alato_.+_admin_role\z/)
          { name: name, type: :enum, options: admin_permission_options(name) }
        end
      end
    end

    # Enum options are owned by the engine that defines the column, exposed as a
    # `Lato::User.<column>_options` class method returning [[label, value], ...].
    def admin_permission_options(name)
      options_method = "#{name}_options"
      Lato::User.respond_to?(options_method) ? Lato::User.public_send(options_method) : []
    end

    # Checks the assigned permission attributes and adds an error for each violation.
    def permissions_valid?(user)
      validate_role_values(user)
      validate_users_admin_flag(user)
      user.errors.empty?
    end

    def validate_role_values(user)
      @available_admin_permissions.select { |permission| permission[:type] == :enum }.each do |permission|
        name = permission[:name]
        next unless user.will_save_change_to_attribute?(name)

        allowed = permission[:options].map { |option| option.last.to_s }
        user.errors.add(name, I18n.t('lato_users.invalid_permission_value')) unless allowed.include?(user[name].to_s)
      end
    end

    def validate_users_admin_flag(user)
      return unless user.persisted? && user.lato_users_admin_was && !user.lato_users_admin

      if user.id == @session.user_id
        user.errors.add(:lato_users_admin, I18n.t('lato_users.cannot_remove_own_admin'))
      elsif last_admin?(user)
        user.errors.add(:lato_users_admin, I18n.t('lato_users.cannot_remove_last_admin'))
      end
    end

    def last_admin?(user)
      user.lato_users_admin_in_database && !Lato::User.where(lato_users_admin: true).where.not(id: user.id).exists?
    end

    # Lato revokes sessions on password change only. A changed email must also cut off
    # whoever holds a session on the old address. The admin's own sessions are kept.
    def revoke_other_sessions(user)
      user.lato_session_records.delete_all unless user.id == @session.user_id
    end

    def deliver_verification_email(user)
      user.request_verify_email
    rescue StandardError => e
      Rails.logger.error(e)
      user.errors.add(:base, I18n.t('lato_users.verification_email_failed'))
      false
    end
  end
end
