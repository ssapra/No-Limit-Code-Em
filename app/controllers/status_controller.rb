class StatusController < ApplicationController

  before_filter :admin_signed_in?

  
  def status
    if params[:type] == "registration"
      status = Status.first
      if status.registration
        status.registration = false
        status.save
      else 
        call_rake :start_registration
      end
      respond_to do |format|
        format.html { redirect_to display_path }
      end
    end
    
    if params[:type] == "game"
      status = Status.first
      if status.game
        call_rake :stop_game
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
