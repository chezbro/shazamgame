Rails.application.routes.draw do

  resources :points
  get 'landings/index'
  
  resources :weeks

  resources :users, only: [:show]

  resources :games do 
    resources :selections, except: :index
  end

  get 'selections' => 'selections#index', as: :selections

  post 'teams' => 'teams#create'

  get 'disable_selections' => 'games#disable_selections', as: :disable_selections

  post 'disable_picks' => 'games#disable_picks', as: :disable_picks

  resources :announcements

  get    "instructions"   => "landings#instructions",         as: :instructions

  get    "stats"   => "landings#stats",         as: :stats

  get    "users"   => "landings#users",         as: :users

  get    "real_time_scores"   => "landings#real_time_scores",         as: :real_time_scores

  get    "activity"   => "landings#activity",         as: :activity




  devise_for :users, controllers: {registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords"}, skip: [:sessions, :registrations]
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  #->Prelang (user_login:devise/stylized_paths)
  devise_scope :user do
    get    "login"   => "users/sessions#new",         as: :new_user_session
    post   "login"   => "users/sessions#create",      as: :user_session
    delete "signout" => "users/sessions#destroy",     as: :destroy_user_session
    
    get    "signup"  => "users/registrations#new",    as: :new_user_registration
    post   "signup"  => "users/registrations#create", as: :user_registration
    put    "signup"  => "users/registrations#update", as: :update_user_registration
    get    "account" => "users/registrations#edit",   as: :edit_user_registration
  end



# If Logged In, go to Game/index, if not go to Landings/Index
  authenticated :user do
    root to: 'landings#activity', as: :authenticated_root
  end
  
  root to: 'landings#index'


end
