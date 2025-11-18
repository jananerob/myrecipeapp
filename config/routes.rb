Rails.application.routes.draw do
  devise_for :users
  resources :recipes do 
    member do
      post 'save', to: 'recipes#save_to_cookbook', as: :save_to_cookbook
      delete 'remove', to:  'recipes#remove_from_cookbook', as: :remove_from_cookbook
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'my_recipes', to: 'recipes#my_recipes', as: :my_recipes
  get 'cookbook', to: 'recipes#cookbook', as: :cookbook

  get "up" => "rails/health#show", as: :rails_health_check
  get 'project-plan', to: 'pages#plan', as: :project_plan
  get 'project-notes', to: 'pages#notes', as: :project_notes

# Defines the root path route ("/")
  root "pages#home"
end
