class FileController < ApplicationController
  @uploadedFile
  @lines

  def upload
  end

  def uploadFile
    if params[:passw1] == params[:passw2]
      if params[:isEncrypt] == '1'
        @value = saveFile(params[:selectedFile])

      #  encryptFile(params[:selectedFile], params[:passw1])
      #  puts(@lines)
      end

    else
      redirect_back fallback_location: '/file/upload',  flash: {result: 'Passwords are not same!'}
    end
  end

  def show(index)

  end

  def downloadFile(filename)
    send_file "#{Rails.root}/public/data/" + filename, type: "application/bin", x_sendfile: true
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
      File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    #result = IO::popen("java -jar FileEncoder.jar " + path + " " + params[:passw1] + " " + params[:isEncrypt])
    Dir.chdir(Rails.root.to_s() + "/public/data/") do
      retResult  = system("java -jar FileEncoder.jar " + name + " " + params[:passw1] + " " + params[:isEncrypt])
      File.delete(Rails.root + path)
    end #chdir
    name + ".bin"
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
