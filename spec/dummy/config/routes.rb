Dummy::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :create, :show, :destroy]
    end
  end
end
