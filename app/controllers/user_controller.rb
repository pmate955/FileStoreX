class UserController < ApplicationController

  def showFiles
    if !user_signed_in?
      redirect_to '/users/sign_in'
    else
      @list = current_user.File_Items
    end
  end

  def changeLocale

  end

end
