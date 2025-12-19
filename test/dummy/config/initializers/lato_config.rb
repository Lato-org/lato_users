Lato.configure do |config|
  config.application_title = 'Lato example app'
  config.application_version = LatoUsers::VERSION

  config.session_root_path = :documentation_path
end

LatoUsers.configure do |config|
end
