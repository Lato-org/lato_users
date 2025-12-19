pin "lato_users/application", to: "lato_users/application.js"
pin_all_from LatoUsers::Engine.root.join("app/assets/javascripts/lato_users/controllers"), under: "controllers", to: "lato_users/controllers"
