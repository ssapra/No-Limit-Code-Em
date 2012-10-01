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
         PlayerActionLog.destroy_all
         HandLog.destroy_all
         PlayerStateLog.destroy_all
         if Player.all.count > 1
           setup_tables
           Table.all.each do |table|
             table.begin_play
           end
           status.game = true
           status.save!
         end
         respond_to do |format|
           format.html { redirect_to display_path }
         end
      end
    end
  end
end
