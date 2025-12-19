Rails.application.routes.draw do
  mount Lato::Engine => "/lato"
  mount LatoUsers::Engine => "/lato_users"

  root 'application#index'

  get 'documentation', to: 'application#documentation', as: :documentation
end
