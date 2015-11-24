DiscoverbpsV2::Application.routes.draw do
  devise_for :admins, :controllers => { :sessions => "admin/sessions", :registrations => "admin/registrations", :passwords => "admin/passwords" }
  devise_scope :admin do
    get "admin_sign_in", :to => "admin/sessions#new"
    get "admin_sign_out", :to => "admin/sessions#destroy"
    get "admin_sign_up", :to => "admin/registrations#new"
    get "admin_edit_registration", :to => "admin/registrations#edit"
  end

  devise_for :users, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :omniauth_callbacks => "users/omniauth_callbacks", :passwords => 'users/passwords' }

  root :to => 'students#index'
  match 'home' => 'students#index'

  resources :students do
    get 'addresses', on: :member
    put 'verify_address', on: :member
    get 'awc', on: :member
    put 'set_awc', on: :member
    get 'ell', on: :member
    put 'set_ell', on: :member
    get 'sped', on: :member
    put 'set_sped', on: :member
    post 'save_preference', on: :member
    post 'remove_notification', on: :collection
  end

  resources :student_schools do
    get 'index', on: :collection
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
    root :to => "students#index"
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

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
