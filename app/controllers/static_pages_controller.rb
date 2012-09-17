class StaticPagesController < ApplicationController
  def home
    if admin_signed_in?
      redirect_to display_path
    end
  end
end
