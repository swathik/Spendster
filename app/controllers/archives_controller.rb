class ArchivesController < ApplicationController
  
  def index
    @archives = Archive.where(user_emails: current_user.email).page(params[:page]).per(5)
  end
end