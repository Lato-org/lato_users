module LatoUsers
  class UsersController < ApplicationController
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

    def create
      @user = Lato::User.new(user_params.merge(
        accepted_privacy_policy_version: Lato.config.legal_privacy_policy_version,
        accepted_terms_and_conditions_version: Lato.config.legal_terms_and_conditions_version
      ))
      if @user.save
        redirect_to users_path
      else
        render 'new'
      end
    end

    def edit
      @user = Lato::User.find(params[:id])
    end

    def update
      @user = Lato::User.find(params[:id])
      if @user.update(user_params)
        redirect_to users_path
      else
        render 'edit'
      end
    end

    def destroy
      if params[:id]&.to_i == @session.user_id
        redirect_to users_path, alert: I18n.t('lato_users.cannot_delete_self')
        return
      end

      @user = Lato::User.find(params[:id])
      @user.destroy
      redirect_to users_path
    end

    def resend_verification_email
      @user = Lato::User.find(params[:id])
      if @user.request_verify_email
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

    def force_update_password
      @user = Lato::User.find(params[:id])
      new_password = SecureRandom.hex(8)
      if @user.update(password: new_password, password_confirmation: new_password)
        redirect_to user_path(@user), notice: I18n.t('lato_users.password_updated', password: new_password)
      else
        redirect_to user_path(@user), alert: I18n.t('lato_users.password_update_failed')
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation)
    end
  end
end