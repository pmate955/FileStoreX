class FileController < ApplicationController
  def upload
  end

  def uploadFile
    if params[:passw1] == params[:passw2]
      if params[:isEncrypt] == 1
        encryptFile(params[:selectedFile], params[:passw1])
      end

    else
      redirect_back fallback_location: '/file/upload',  flash: {result: 'Passwords are bad'}
    end
  end

  def show(index)

  end


protected
  def user_params
    params.require(:user).permit(:isEncrypt, :selectedFile, :passw1, :passw2)
  end

  private
  def encryptFile(file, pass)

  end

end
