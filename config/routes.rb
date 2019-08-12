Rails.application.routes.draw do

  get 'landings/index'

  resources :points

  resources :weeks

  resources :users, only: [:show]

  resources :games do
    resources :selections, except: :index
  end

  resources :announcements

  resources :messages

  get 'selections' => 'selections#index', as: :selections
  post 'teams' => 'teams#create'
  get 'enable_disable_selections' => 'games#enable_disable_selections', as: :enable_disable_selections
  post 'enable_picks' => 'games#enable_picks', as: :enable_picks
  post 'disable_picks' => 'games#disable_picks', as: :disable_picks
  get    "instructions"   => "landings#instructions",         as: :instructions
  get    "stats"   => "landings#stats",         as: :stats
  get    "favorite-teams"   => "landings#favorite_teams",         as: :favorite_teams
  get    "last-week"   => "landings#last_week_leaders",         as: :last_week_leaders
  get    "users"   => "landings#users",         as: :users
  get    "player_selections"   => "landings#player_selections",         as: :player_selections
  get    "real_time_scores"   => "landings#real_time_scores",         as: :real_time_scores
  get    "activity"   => "landings#activity",         as: :activity
  get    "email_reminders_page"   => "landings#email_reminders_page",         as: :email_reminders_page
  get    "activate_profile"   => "users#activate_profile",         as: :activate_profile
  get    "deactivate_profile"   => "users#deactivate_profile",         as: :deactivate_profile
  get    "delete_user"   => "users#delete_user",         as: :delete_user
  get    "reset_selections"   => "selections#reset_selections",         as: :reset_selections
  post   "send_reminder_email"   => "landings#send_reminder_email",         as: :send_reminder_email
  get 'game_reset' => 'games#game_reset', as: :game_reset

  devise_for :users, controllers: {registrations: "users/registrations", sessions: "users/sessions", passwords: "users/passwords"}, skip: [:sessions, :registrations]

  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

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
