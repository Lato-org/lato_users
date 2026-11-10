module LatoUsers
  class InvitationsController < ApplicationController
    def index
      @invitations = lato_index_collection(
        Lato::Invitation.all,
        columns: %i[email accepted_at created_at actions],
        searchable_columns: %i[email],
        sortable_columns: %i[email accepted_at created_at],
        pagination: true,
        default_sort_by: "created_at|desc"
      )
    end

    def new
      @invitation = Lato::Invitation.new
    end

    # The invitation is persisted before the mail is sent: when delivery fails
    # the admin is told so and can retry with the resend action.
    def create
      @invitation = Lato::Invitation.new(invitation_params.merge(inviter_lato_user_id: @session.user_id))
      if !save_invitation
        render 'new', status: :unprocessable_entity
      elsif @invitation.errors.any?
        redirect_to invitations_path, alert: delivery_failure_message(@invitation)
      else
        redirect_to invitations_path, notice: I18n.t('lato_users.invitation_created')
      end
    end

    def resend
      @invitation = Lato::Invitation.find(params[:id])
      if @invitation.send_invite
        redirect_to invitations_path, notice: I18n.t('lato_users.invitation_resent')
      else
        redirect_to invitations_path, alert: delivery_failure_message(@invitation)
      end
    rescue StandardError => e
      Rails.logger.error(e)
      redirect_to invitations_path, alert: I18n.t('lato_users.invitation_email_failed')
    end

    def destroy
      @invitation = Lato::Invitation.find(params[:id])
      if @invitation.destroy
        redirect_to invitations_path, notice: I18n.t('lato_users.invitation_destroyed')
      else
        redirect_to invitations_path, alert: I18n.t('lato_users.cannot_delete_accepted_invitation')
      end
    end

    private

    def invitation_params
      params.require(:invitation).permit(:email)
    end

    # Mail delivery raising inside the after_create hook rolls the record back.
    def save_invitation
      @invitation.save
    rescue StandardError => e
      Rails.logger.error(e)
      @invitation.errors.add(:base, I18n.t('lato_users.invitation_email_failed'))
      false
    end

    def delivery_failure_message(invitation)
      messages = invitation.errors.full_messages.join(', ')
      [I18n.t('lato_users.invitation_email_failed'), messages.presence].compact.join(': ')
    end
  end
end
