ServerApp::Application.routes.draw do
  
  post "/action" => 'status#action', :as => :action

  devise_for :admins
  
  get "/" => 'static_pages#home'
  get "/requests" => 'requests#display', :as => :display
  get "/nothing" => 'requests#nothing', :as => :nothing
  post "/" => 'requests#post'
  get "/states" => 'requests#states', :as => :states
  get "/setup" => 'games#setup', :as => :setup
  
end
