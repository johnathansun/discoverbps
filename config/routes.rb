DiscoverBPS::Application.routes.draw do
  devise_for :admins, controllers: { sessions: "admin/sessions", registrations: "admin/registrations", passwords: "admin/passwords" }
  devise_scope :admin do
    get "admin_sign_in", to: "admin/sessions#new"
    get "admin_sign_out", to: "admin/sessions#destroy"
    get "admin_sign_up", to: "admin/registrations#new"
    get "admin_edit_registration", to: "admin/registrations#edit"
  end

  devise_for :users, controllers: { sessions: "users/sessions", registrations: "users/registrations", omniauth_callbacks: "users/omniauth_callbacks", passwords: 'users/passwords' }

  root to: 'students#new'
  match 'home' => 'students#new'

  resources :choice_schools do
    get 'verify', on: :collection
    post 'send_verification', on: :collection
    get 'confirmation', on: :collection
    post 'authenticate', on: :collection
    get 'list', on: :collection
    get 'order', on: :collection
    post 'rank', on: :collection
    get 'summary', on: :collection
    post 'submit', on: :collection
    get 'success', on: :collection
  end

  resources :students do
    post 'save_preference', on: :member
    post 'remove_notification', on: :collection
    post 'switch_current', on: :member
  end

  resources :student_addresses, only: [:new, :create]
  resources :student_awc_preferences, only: [:new, :create]
  resources :student_ell_preferences, only: [:new, :create]
  resources :student_sped_preferences, only: [:new, :create]

  resources :student_schools do
    post 'sort', on: :collection
    post 'star', on: :member
    post 'unstar', on: :member
    post 'add_another', on: :member
  end

  resources :schools do
    get 'home', on: :collection
    get 'zone_schools', on: :collection
    get 'print_lists', on: :collection
    get 'print', on: :member
    get 'compare', on: :collection
    get 'get_ready', on: :collection
  end

  namespace :admin do
    root to: "students#index"
    resources :admins
    resources :demand_data do
      delete 'delete_all', on: :collection
    end
    resources :docs, only: [:index]
    resources :preferences do
      post 'sort', on: :collection
    end
    resources :preference_categories do
      post 'sort', on: :collection
    end
    resources :notifications
    resources :schools do
      post 'sync', on: :member
      post 'sync_all', on: :collection
    end
    resources :students, path: 'searches'
    resources :text_snippets
  end
end
