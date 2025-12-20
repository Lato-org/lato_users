module LatoUsers
  module InvitationsHelper
    def lato_invitation_created_at(invitation)
      I18n.l(invitation.created_at, format: :short)
    end

    def lato_invitation_accepted_at(invitation)
      if invitation.accepted_at.present?
        I18n.l(invitation.accepted_at, format: :short)
      else
        ' - '
      end
    end
  
    def lato_invitation_actions(invitation)
      content_tag(:div, class: 'btn-group btn-group-sm') do
        if invitation.accepted_at.nil?
          concat link_to(I18n.t('lato_users.cta_delete'), lato_users.invitation_path(invitation), class: 'btn btn-danger', data: { turbo_confirm: I18n.t('lato_users.cta_delete_confirm'), turbo_method: :delete, turbo_frame: '_top' })
        else
          concat content_tag(:button, I18n.t('lato_users.cta_delete'), class: 'btn btn-danger', disabled: true, title: I18n.t('lato_users.cannot_delete_accepted_invitation'))
        end
      end
    end
  end
end