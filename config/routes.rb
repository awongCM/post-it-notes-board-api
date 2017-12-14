Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  if Rails.env.production?
    namespace :api, path: '/' do
      namespace :v1 do
        resources :notes
      end
    end
  else
    namespace :api, path: '/' do
      namespace :v1 do
        resources :notes, constraints: {subdomain: 'api'}  
      end
    end
  end
end
