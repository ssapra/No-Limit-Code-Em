class StatusController < ApplicationController

  before_filter :admin_signed_in?

  
  def status
    if params[:type] == "registration"
      status = Status.first
      if status.registration
         status.registration = false
         status.save!
      else 
         status.registration = true
         Player.destroy_all
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
        call_rake :start_game
        respond_to do |format|
         format.html { redirect_to display_path }
        end
      end
    end
  end
end
