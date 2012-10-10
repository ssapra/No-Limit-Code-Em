class SandboxController < ApplicationController
  
  def action
    name = params[:name]
    game_id = params[:game_id]
    player_key = params[:player_key]
    player_action = params[:player_action]
    parameters = params[:parameters]
    actions = ["check", "bet", "call", "raise", "fold"]
    
    body = ["---Received---",
            "Name: #{name}",
            "ID: #{game_id}",
            "Player key: #{player_key}",
            "Action: #{params[:player_action]}",
            "Parameters: #{params[:parameters]}"]
            
    if actions.include?(player_action)
      body.push("", "Valid Action", "")
    else
      body.push("", "Invalid Action: #{player_action}", "")
    end
    
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.xml  {render :xml => body, :status => 200}
    end
  end
  
  
  def current_turn
    
    body = {:current_player => "Joe", 
            :replacement => false,
            :hand => ["5c", "8d", "3d", "As", "Kh"], 
            :bet => 100, 
            :stack => 400, 
            :pot => 300,
            :min_bet => 150,
            :max_bet => 300,
            :max_raise => 200,
          }
             
    body[:betting_summary] = ["John bets 200",
                            "Sally calls 200"]
    body[:replacement_summary] = ["John replaced 2 cards",
                                  "Sally replaced 0 cards"]       
    body[:round_summary] = ['John won 200 chips with ["5c", "3d", "8h", "9d", "Ac"] for Hand#16']
    body[:play] = true
    body[:waiting] = false
    body[:game_over] = false
    logger.debug "body: #{body}"
    
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.xml  {render :xml => body, :status => 200}
    end
    
  end
  
  def game_over
    summary = ["Tournament is Over.",
               " ", 
               "Player Standings", 
               "----------------",
               "1. Player A",
               "2. Player C",
               "3. Player B"]
               
    previous_winner = ['John won 200 chips with ["5c", "3d", "8h", "9d", "Ac"] for Hand#16',
                       'Sally won 1200 chips with ["4c", "8c", "2c", "9c", "Tc"] for Hand#17']
    
    body = {:message => "Tournament is Over", 
            :winning_summary => summary, 
            :round_summary => previous_winner, 
            :game_over => true}
            
    respond_to do |format|
      format.html {render :json => body, :status => 200}
      format.xml  {render :xml => body, :status => 200}
    end
  end
  
end
