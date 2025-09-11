Rails.application.routes.draw do

  get 'landings/index'

  resources :points

  resources :weeks do
    member do
      patch :close_week
      patch :reset_week
    end
  end

  resources :users, only: [:show]

  resources :games do

    resources :selections, except: :index
    get    "home_team_selections"   => "games#home_team_selections",         as: :home_team_selections
    get    "away_team_selections"   => "games#away_team_selections",         as: :away_team_selections

  end

  resources :announcements

  resources :messages

  get 'selections' => 'selections#index', as: :selections
  post 'teams' => 'teams#create'
  get 'enable_disable_selections' => 'games#enable_disable_selections', as: :enable_disable_selections
  get  'hide_and_unhide'   => 'games#hide_and_unhide',         as: :hide_and_unhide
  post 'hide_games' => 'games#hide_games', as: :hide_games
  post 'unhide_games' => 'games#unhide_games', as: :unhide_games
  post 'enable_picks' => 'games#enable_picks', as: :enable_picks
  post 'disable_picks' => 'games#disable_picks', as: :disable_picks
  get    "instructions"   => "landings#instructions",         as: :instructions
  get    "stats"   => "landings#stats",         as: :stats
  get    "favorite-teams"   => "landings#favorite_teams",         as: :favorite_teams
  get    "last-week"   => "landings#last_week_leaders",         as: :last_week_leaders
  get    "users"   => "landings#users",         as: :users
  get    "player_selections"   => "landings#player_selections",         as: :player_selections
  get    "team_selections"   => "landings#team_selections",         as: :team_selections
  
  get    "real_time_scores"   => "landings#real_time_scores",         as: :real_time_scores
  get    "activity"   => "landings#activity",         as: :activity
  get    "email_reminders_page"   => "landings#email_reminders_page",         as: :email_reminders_page
  get    "activate_profile"   => "users#activate_profile",         as: :activate_profile
  get    "deactivate_profile"   => "users#deactivate_profile",         as: :deactivate_profile
  get    "delete_user"   => "users#delete_user",         as: :delete_user
  get    "reset_selections"   => "selections#reset_selections",         as: :reset_selections
  post   "send_reminder_email"   => "landings#send_reminder_email",         as: :send_reminder_email
  get 'game_reset' => 'games#game_reset', as: :game_reset
  post 'game_update' => 'games#game_update', as: :game_update
  get 'reset_the_week' => 'games#reset_the_week', as: :reset_the_week
  get 'restore_week1_scores' => 'games#restore_week1_scores', as: :restore_week1_scores
  get 'force_score_active_week' => 'games#force_score_active_week', as: :force_score_active_week

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
