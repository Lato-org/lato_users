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

    def create
      @invitation = Lato::Invitation.new(invitation_params.merge(inviter_lato_user_id: @session.user_id))
      if @invitation.save
        redirect_to invitations_path, notice: I18n.t('lato_users.invitation_created')
      else
        render 'new'
      end
    end

    def destroy
      @invitation = Lato::Invitation.find(params[:id])
      @invitation.destroy
      redirect_to invitations_path, notice: I18n.t('lato_users.invitation_destroyed')
    end

    private

    def invitation_params
      params.require(:invitation).permit(:email)
    end
  end
end