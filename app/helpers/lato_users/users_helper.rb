module LatoUsers
  module UsersHelper
    def lato_user_actions(user, show: true)
      content_tag(:div, class: 'btn-group btn-group-sm') do
        concat link_to(I18n.t('lato_users.cta_show'), lato_users.user_path(user), class: 'btn btn-secondary', aria: { label: I18n.t('lato_users.cta_show_user', name: user.email) }, data: { turbo_frame: '_top' }) if show
        concat link_to(I18n.t('lato_users.cta_edit'), lato_users.edit_user_path(user, redirect_to: request.fullpath), class: 'btn btn-primary', aria: { label: I18n.t('lato_users.cta_edit_user', name: user.email) }, data: { lato_action_target: 'trigger', turbo_frame: dom_id(user, 'form'), action_title: I18n.t('lato_users.edit_user') })
        if user.id == @session.user_id
          concat lato_disabled_delete_button(user, dom_id(user, 'delete_hint'), I18n.t('lato_users.cannot_delete_self'))
        else
          concat link_to(I18n.t('lato_users.cta_delete'), lato_users.user_path(user), class: 'btn btn-danger', aria: { label: I18n.t('lato_users.cta_delete_user', name: user.email) }, data: { turbo_confirm: I18n.t('lato_users.cta_delete_confirm', name: user.email), turbo_method: :delete, turbo_frame: '_top' })
        end
      end
    end

    # Same markup as lato_form_item_input_check, but the label points to the checkbox id.
    # lato's helper builds `for="<column>"` while Rails generates `user_<column>`, so the
    # label would not be associated with the input.
    def lato_user_permission_check(form, user, name, label)
      check_id = "#{dom_id(user, 'permission')}_#{name}"
      options = { id: check_id }
      _lato_form_input_options(form, name, options, :change, 'form-check-input')

      content_tag(:div, class: 'form-check') do
        concat form.check_box(name, options)
        concat form.label(name, label, for: check_id, class: 'form-check-label')
      end
    end

    private

    # aria-disabled (not `disabled`) keeps the button focusable so the reason is reachable by keyboard and screen readers.
    def lato_disabled_delete_button(user, hint_id, reason)
      button = content_tag(:button, I18n.t('lato_users.cta_delete'), type: 'button', class: 'btn btn-danger disabled', aria: { disabled: true, label: I18n.t('lato_users.cta_delete_user', name: user.email), describedby: hint_id }, title: reason)
      button + content_tag(:span, reason, id: hint_id, class: 'visually-hidden')
    end
  end
end
