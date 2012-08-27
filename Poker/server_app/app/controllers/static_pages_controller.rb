class StaticPagesController < ApplicationController
  def home
    if current_admin
      redirect_to display_path
    end
  end
end
