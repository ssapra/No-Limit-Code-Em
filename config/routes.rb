ServerApp::Application.routes.draw do

  get "/" => 'home#index', :as => :root
  post "/" => 'requests#registration' #player registers here
  post "/refresh" => 'home#update' #player registers here

  get "/requests" => 'requests#display', :as => :display #admin display page
  get "/registration" => 'requests#new_player', :as => :register
  post "/status" => 'status#status', :as => :status #used to toggle game states

  get "/game_state" => 'requests#state', :as => :states #player asks for state
  post "/player" => 'requests#player_turn' #player sends action here

  ####### Sandbox Routes
  post "/sandbox/player_action" => 'sandbox#action'
  post "/sandbox/betting_round" => 'sandbox#action'
  get "/sandbox/current_turn" => 'sandbox#current_turn'
  get "/sandbox/game_over" => 'sandbox#game_over'

end
