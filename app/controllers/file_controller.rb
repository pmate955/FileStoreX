class FileController < ApplicationController
  @uploadedFile
  @lines

  def upload
  end

  def uploadFile
    if params[:passw1] == params[:passw2]
      if params[:isEncrypt] == 'true'
        saveFile(params[:selectedFile])
      #  encryptFile(params[:selectedFile], params[:passw1])
      #  puts(@lines)
      end

    else
      redirect_back fallback_location: '/file/upload',  flash: {result: 'Passwords are not same!'}
    end
  end

  def show(index)

  end


protected
  def user_params
    params.require(:user).permit(:isEncrypt, :selectedFile, :passw1, :passw2)
  end

  private

  def saveFile(upload)
    name = upload['datafile'].original_filename
    directory = "public/data"
    # create the file path
    path = File.join(directory, name)
    # write the file
   # puts(upload['datafile'].read)
    contents = IO.binread(upload['datafile'].path)
    puts(contents)
    for pos in 0...contents.length
      puts contents[pos].
    end
      #File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end

  def encryptFile(file, pass)
    puts('Encrypt')
    @uploadedFile = file
    if  @uploadedFile.respond_to?(:read)
      @lines = file_data.read
    elsif  @uploadedFile.respond_to?(:path)
      @lines = File.read(file_data.path)
    else
      logger.error "Bad file_data: #{ @uploadedFile.class.name}: #
    {@filename.inspect}"
    end
  end

end
