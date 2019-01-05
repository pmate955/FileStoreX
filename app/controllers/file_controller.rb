require 'dropbox'

class FileController < ApplicationController
  @uploadedFile
  @lines


  def upload
  end



  def uploadFile
    @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
   # folder = @dbx.create_folder('/firstFolder')
   # @dbx.upload('/firstFolder/' + params[:selectedFile]['datafile'].original_filename, params[:selectedFile]['datafile'].read)
    if params[:passw1] == params[:passw2]
      if params[:isEncrypt] == '1'
       @value = saveFile(params[:selectedFile])
      else
        value = saveFile(params[:selectedFile])
        index = value.index(".bin")
        @value = value[0...index]
      end
    else
      redirect_back fallback_location: '/file/upload',  flash: {result: 'Passwords are not same!'}
    end
  end

  def show
    @file_id = params[:file_id]
    unless fileItem = FileItem.find_by(id: params[:file_id])
      redirect_to('/file/not_found')
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def downloadFile
    file_path = "#{Rails.root}/public/data/" + params[:filename]
    # send_file "#{Rails.root}/public/data/" + params[:filename], type: "application/bin", x_sendfile: true
    File.open(file_path, 'r') do |f|
      send_data f.read, :filename => params[:filename]
    end
    File.delete(file_path)

    # @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
   # file, body = @dbx.download('/firstFolder/' + params[:filename])
   #   send_data body.to_s, :filename => params[:filename]
   #   @dbx.delete('/firstFolder/'+ params[:filename])
      #File.delete(file_path)
  end

  def downloadEnc
    unless fileItem = FileItem.find(params[:file_id])
      redirect_to '/file/not_found'
    end
    file_path = fileItem.path
    if file_path.end_with?'.bin'
        @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
        file, body = @dbx.download(file_path)
        send_data body.to_s, :filename => File.basename(fileItem.path)
    end
  end

  def uploadUserFile

  end

  def uploadUserFilePost
    if current_user.File_Items.size > 5
      redirect_back fallback_location: '/file/uploadUserFile',  flash: {result: 'You exceeded the file limit, maximum 5 files / user!'}
    end
    if params[:passw1] == params[:passw2]
      @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
      path = saveUserFile(params[:selectedFile])
      fileItem = FileItem.new(:path => path, :password => params[:passw1], :user_id => current_user.id)
      fileItem.save()
      redirect_to '/user/showFiles'
    else
      redirect_back fallback_location: '/file/uploadUserFile',  flash: {result: 'Passwords are not same!'}
    end
  end

  def deleteFile
    fileItem = FileItem.find(params[:file_id])
    @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
    @dbx.delete(fileItem.path)
    fileItem.delete
    redirect_to '/user/showFiles'
  end

  def not_found

  end

  def tryPass
    unless fileItem = FileItem.find(params[:file_id])
      redirect_to '/file/not_found'
    end
    if fileItem.password == params[:passw1]
      file_path = fileItem.path
      @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
      file, body = @dbx.download(file_path)
      if File.basename(fileItem.path).end_with?'.bin'
        output = ''.bytes.to_a
        key = params[:passw1].bytes.to_a
        index = 0
        oIndex = 0
        body.to_s.each_byte do |byte|
          output[oIndex] = byte ^ key[index]
          index += 1
          oIndex += 1
          if index == key.size
            index = 0
          end
        end
        send_data output.pack('c*'), :filename => File.basename(fileItem.path)[0...File.basename(fileItem.path).index('.bin')]
      else
        send_data body.to_s, :filename => File.basename(fileItem.path)
      end
      fileItem.status = 'Downloaded'
      fileItem.increment(:downloadedNum, 1)
      fileItem.save
    else
      redirect_back fallback_location: '/file/show',  flash: {result: t('show.badpass')}
    end
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
    data = File.read(upload['datafile'].path)
    output = ''.bytes.to_a
    key = params[:passw1].bytes.to_a
    index = 0
    oIndex = 0
    data.each_byte do |byte|
     output[oIndex] = byte ^ key[index]
      index += 1
      oIndex += 1
      if index == key.size
        index = 0
      end
    end
    Dir.chdir("public/data/") do
      if params[:isEncrypt] == '1'
        File.open(name+ '.bin', "wb") { |f| f.write(output.pack('c*'))}
      #  @dbx.upload('/firstFolder/' + name + ".bin", File.read(name + '.bin'))
      else
        index = name.index(".bin")
        name2 = name[0...index]
       File.open(name2, "wb") { |f| f.write(output.pack('c*'))}
      #  @dbx.upload('/firstFolder/' + name2, File.read(name2))
      end
    end
    name + ".bin"
  end

  def saveUserFile(upload)
    name = upload['datafile'].original_filename
    data = File.read(upload['datafile'].path)
    output = ''.bytes.to_a
    key = params[:passw1].bytes.to_a
    index = 0
    oIndex = 0
    data.each_byte do |byte|
      output[oIndex] = byte ^ key[index]
      index += 1
      oIndex += 1
      if index == key.size
        index = 0
      end
    end
    directory = "/firstFolder/" + current_user.id.to_s + "/"
    path = File.join(directory, name + '.bin')
    @dbx = Dropbox::Client.new('weix-inyuvAAAAAAAAAADZEZVWLlf4RvDREOjiZCBGS-Hd3bAO0AU6dPPDeY9ocp')
    list = @dbx.list_folder('/firstFolder/')
    findFolder = false
    list.each do |item|
      if item.name == current_user.id.to_s
        findFolder = true
        break
      end
    end
    if findFolder == false
      @dbx.create_folder("/firstFolder/" + current_user.id.to_s)
    end
    @dbx.upload(path, output.pack('c*'))     
    return path
  end


end
