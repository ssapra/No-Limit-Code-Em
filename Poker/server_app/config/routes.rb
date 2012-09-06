ServerApp::Application.routes.draw do

  devise_for :admins
  
  get "/" => 'static_pages#home'
  post "/" => 'requests#post'
  
  get "/requests" => 'requests#display', :as => :display
  get "/nothing" => 'requests#nothing', :as => :nothing
  get "/states" => 'requests#states', :as => :states
  get "/setup" => 'games#setup', :as => :setup
  
  
  post "/status" => 'status#status', :as => :status
  post "/action" => 'games#action',:as => :action
  
  get "/poker" => 'games#poker', :as => :poker
end
