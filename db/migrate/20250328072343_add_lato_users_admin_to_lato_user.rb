class AddLatoUsersAdminToLatoUser < ActiveRecord::Migration[7.1]
  def change
    add_column :lato_users, :lato_users_admin, :boolean, default: false
  end
end
