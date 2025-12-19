module LatoUsers
  class ApplicationController < Lato::ApplicationController
    layout 'lato/application'
    before_action :authenticate_session
    before_action :authenticate_lato_users_admin
    before_action { active_sidebar(:lato_users); active_navbar(:lato_users) }

    def index
      redirect_to lato_users.users_path
    end

    protected

    def authenticate_lato_users_admin
      return true if @session.user&.lato_users_admin

      redirect_to lato.root_path, alert: 'You have not access to this section.'
    end
  end
end