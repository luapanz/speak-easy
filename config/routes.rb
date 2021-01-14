Rails.application.routes.draw do

  get 'legal/privacy'

  get 'home/dashboard'

  post 'home/action'

  get 'call_actions/new'

  get 'signup/personal'

  get 'agents/invite'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  # Rails.application.routes.draw do

  get 'legal/privacy'

  get 'home/dashboard'

  post 'home/action'

  post 'agents/createlink'

  get 'call_actions/new'

  get 'signup/personal'

  get 'agents/invite'

  #   devise_for :users, controllers: {
  #       sessions: 'users/sessions'
  #   }
  # end

  root 'sessions#new'

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :agents
  resources :locations
  resources :campaigns
  get '/pastcampaigns', :to => 'campaigns#past_campaigns'
  get '/activecampaigns', :to => 'campaigns#current_campaigns'
  get '/futurecampaigns', :to => 'campaigns#future_campaigns'
  resources :announcements
  resources :users, path: 'agents'
  resources :home
  resources :chat
  resources :settings
  resources :billing

  resources :signup
  resources :extra
  resources :agent_signup
  resources :subscribe
  resources :agents_campaign_signup
  resources :enroll

  match '/ajax/check_username' => 'ajax#check_username', :via => :post
  match '/ajax/check_email' => 'ajax#check_email', :via => :post
  match '/ajax/verify_email' => 'ajax#verify_email', :via => :post
  match '/ajax/cancel_campaign' => 'ajax#cancel_campaign', :via => :post
  match '/ajax/send_sms' => 'ajax#send_sms', :via => :post
  match '/ajax/subscribe' => 'ajax#subscribe', :via => :post
  match '/ajax/change_password' => 'ajax#change_password', :via => :post
  match '/ajax/send_team_sms' => 'ajax#send_team_sms', :via => :post
  match '/ajax/update_subscription' => 'ajax#update_subscription', :via => :post
  match '/ajax/update_card' => 'ajax#update_card', :via => :post
  match '/ajax/cancel_subscription' => 'ajax#cancel_subscription', :via => :post
  match '/ajax/update_users_subscription' => 'ajax#update_users_subscription', :via => :post
  match '/ajax/disable_onboarding_dialog' => 'ajax#disable_onboarding_dialog', :via => :post
  
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  get 'logout' => 'sessions#destroy'

  match '/account' => 'account#index', :via => :get
  match '/account' => 'account#update', :via => :put
  match '/password' => 'password#index', :via => :get
  match '/password' => 'password#update', :via => :put

  match '/restore' => 'restore#index', :via => :get
  match '/restore' => 'restore#update', :via => :put

  match '/business' => 'business#index', :via => :get
  match '/business' => 'business#update', :via => :put

  match '/billing' => 'billing#index', :via => :get

  #match '/agents_campaign' => 'agents_campaign_signup', :via => :get

  # resources :sessions, only: [:create, :destroy]

  # get 'signup' => 'sessions#signup'

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
end
