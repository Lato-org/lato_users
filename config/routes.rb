LatoUsers::Engine.routes.draw do
  root 'application#index'

  resources :users do
    member do
      post :resend_verification_email
      patch :manual_verify_email
      patch :revoke_email_verification
      patch :force_update_password
    end
  end

  resources :invitations, except: [:show, :edit, :update]
end
