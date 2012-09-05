class GamesController < ApplicationController
  include RubyPoker
  
  def setup
    
    deck = Deck.new
     logger.debug "Deck : #{deck.inspect}"
     #logger.debug "Cards: #{deck[:cards]}"
     table_deck = [] 
     deck.size.times do
       table_deck << deck.deal.to_s.gsub(/-/,"") .gsub(/'/," ")
     end
     
     table = Table.new(:deck => table_deck, :pot => 0)
     table.save
     
     
     Player.all.each do |player|
       Seat.create(:table_id => table.id, :player_id => player.id)
       player.hand = []
       player.save
     end
     
     5.times do 
       Player.all.each do |player|  
         player.hand << table.deck.pop.to_s.gsub(/-/,"") .gsub(/'/," ")
         logger.debug "hand: #{player.hand}"
         player.save
       end
     end
     
     table.turn_id = table.seats.first.player_id
     table.save
  
     respond_to do |format|
       format.html { redirect_to display_path}
     end
  end
  
  
end