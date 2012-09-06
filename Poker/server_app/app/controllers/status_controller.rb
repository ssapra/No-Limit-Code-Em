class StatusController < ApplicationController

  def status
    if params[:type] == "registration"
      status = Status.first
      if status.registration
         status.registration = false
         status.save!
      else 
         status.registration = true
         status.save!
      end
      respond_to do |format|
        format.html { redirect_to display_path }
      end
    end
    
    if params[:type] == "game"
      status = Status.first
      if status.game
         status.game = false
         status.save!
         
         respond_to do |format|
           format.html { redirect_to display_path }
         end
      else 
         status.game = true
         status.save!
         Table.destroy_all
         table = Table.new
         table.setup
         respond_to do |format|
           format.html { redirect_to display_path }
         end
      end
    end
    
    if params[:type] == "play"
      status = Status.first
      if status.play
         status.play = false
         status.save!
      else 
         status.play = true
         status.save!
         table = Table.first
         table.next_action
      end
      respond_to do |format|
         format.html { redirect_to display_path }
       end
    end
  end
end