WizardRails::Application.routes.draw do


  get "offers/show"

  resources :articles

  get "tags/new"

  get "tags/create"

  get "tags/index"

  get 'sitemap', :to => 'sitemap#show.xml'

  resources :user_requests, :path => "conseiller-virtuel", :only => [:create, :update, :edit, :index], :path_names =>  {:edit => "questionnaire", :user_response => "resultats"} do
    get 'user_response', :on => :member
  end

  resources :products, :path => "ordinateurs", :only => [:index, :show]

  get 'mentions-legales' => 'misc#legal', :as => "legal"
  get 'conditions-utilisation' => 'misc#terms', :as => "terms"
  get 'visite-guidee' => 'misc#tour', :as => "tour"
  get 'presse-partenaires' => 'misc#press', :as => "press"
  get 'contact' => 'misc#contact', :as => "contact"

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" => "sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"
  get "admin" => "admin#show", :as => "admin"
  resources :users
  resources :sessions
  resources :tags
  resources :offers
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
  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

