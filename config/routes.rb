Rails.application.routes.draw do
  resources :recipes
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'project-plan', to: 'pages#plan', as: :project_plan
  get 'project-notes', to: 'pages#notes', as: :project_notes

# Defines the root path route ("/")
  root "pages#home"
end
