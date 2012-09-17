ServerApp::Application.routes.draw do

  devise_for :admins
  
  get "/" => 'static_pages#home' 
  post "/" => 'requests#registration' #player registers here
  
  get "/requests" => 'requests#display', :as => :display #admin display page
  get "/game_state" => 'requests#state', :as => :states #player asks for state
  
  post "/status" => 'status#status', :as => :status #used to toggle game states
  post "/player" => 'games#player_turn' #player sends action here
  
end
