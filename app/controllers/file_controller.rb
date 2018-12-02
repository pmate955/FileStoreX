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
      else
        value = saveFile(params[:selectedFile])
        index = value.index(".bin")
        @value = value[0...index]
      end

    else
      redirect_back fallback_location: '/file/upload',  flash: {result: 'Passwords are not same!'}
    end
  end

  def show(index)

  end

  def downloadFile
    file_path = "#{Rails.root}/public/data/" + params[:filename]
   # send_file "#{Rails.root}/public/data/" + params[:filename], type: "application/bin", x_sendfile: true
    File.open(file_path, 'r') do |f|
      send_data f.read, type: "application/bin", :filename => params[:filename]
    end
    File.delete(file_path)
  end

protected
  def user_params
    params.require(:user).permit(:isEncrypt, :selectedFile, :passw1, :passw2)
  end

  private

  def saveFile(upload)
    name = upload['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
    Dir.chdir(Rails.root.to_s() + "/public/data/") do
      retResult  = system("java -jar FileEncoder.jar " + name + " " + params[:passw1] + " " + params[:isEncrypt])
      puts(retResult)
      File.delete(Rails.root + path)
    end
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
