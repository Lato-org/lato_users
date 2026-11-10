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
          concat button_to(I18n.t('lato_users.cta_resend'), lato_users.resend_invitation_path(invitation), method: :post, class: 'btn btn-primary', form_class: 'd-inline-flex', aria: { label: I18n.t('lato_users.cta_resend_invitation', name: invitation.email) }, form: { data: { turbo_frame: '_top' } })
          concat link_to(I18n.t('lato_users.cta_delete'), lato_users.invitation_path(invitation), class: 'btn btn-danger', aria: { label: I18n.t('lato_users.cta_delete_invitation', name: invitation.email) }, data: { turbo_confirm: I18n.t('lato_users.cta_delete_invitation_confirm', name: invitation.email), turbo_method: :delete, turbo_frame: '_top' })
        else
          hint_id = "invitation_#{invitation.id}_delete_hint"
          reason = I18n.t('lato_users.cannot_delete_accepted_invitation')
          concat content_tag(:button, I18n.t('lato_users.cta_delete'), type: 'button', class: 'btn btn-danger disabled', aria: { disabled: true, label: I18n.t('lato_users.cta_delete_invitation', name: invitation.email), describedby: hint_id }, title: reason)
          concat content_tag(:span, reason, id: hint_id, class: 'visually-hidden')
        end
      end
    end
  end
end
