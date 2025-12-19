module LatoUsers
  module UsersHelper
    def lato_user_actions(user)
      content_tag(:div, class: 'btn-group btn-group-sm') do
        concat link_to(I18n.t('lato_users.cta_show'), lato_users.user_path(user), class: 'btn btn-secondary', data: { turbo_frame: '_top' })
        concat link_to(I18n.t('lato_users.cta_edit'), lato_users.edit_user_path(user), class: 'btn btn-primary', data: { lato_action_target: 'trigger', turbo_frame: dom_id(user, 'form'), action_title: I18n.t('lato_users.edit_user') })
        if user.id == @session.user_id
          concat content_tag(:button, I18n.t('lato_users.cta_delete'), class: 'btn btn-danger', disabled: true, title: I18n.t('lato_users.cannot_delete_self'))
        else
          concat link_to(I18n.t('lato_users.cta_delete'), lato_users.user_path(user), class: 'btn btn-danger', data: { turbo_confirm: I18n.t('lato_users.cta_delete_confirm'), turbo_method: :delete, turbo_frame: '_top' })
        end
      end
    end
  end
end