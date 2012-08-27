ServerApp::Application.routes.draw do
  
  devise_for :admins
  
  get "/" => 'static_pages#home'

  get "/requests" => 'requests#display', :as => :display
  get "/nothing" => 'requests#nothing', :as => :nothing
  post "/" => 'requests#post'
  
end
