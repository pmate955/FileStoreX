require 'dropbox'

class FileController < ApplicationController
  @uploadedFile
  @lines


  def upload
  end



  def uploadFile
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
  end

  def downloadEnc
    unless fileItem = FileItem.find(params[:file_id])
      redirect_to '/file/not_found'
    end
    file_path = fileItem.path
    if file_path.end_with?'.bin'
        session = GoogleDrive::Session.from_config("config.json")
        file = session.file_by_title([fileItem.user_id.to_s, File.basename(file_path) ])
        body = file.download_to_string
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
    session = GoogleDrive::Session.from_config("config.json")
    file = session.file_by_title([fileItem.user_id.to_s, File.basename(fileItem.path) ])
    file.delete(true)
    fileItem.delete
    redirect_to '/user/showFiles'
  end

  def not_found

  end

  def searchFile
    puts(params[:searchedID])
    if FileItem.exists?(params[:searchedID])
      redirect_to :controller => 'file', :action => 'show', :file_id => params[:searchedID]
    else
      redirect_to '/file/not_found'
    end

  end

  def tryPass
    unless fileItem = FileItem.find(params[:file_id])
      redirect_to '/file/not_found'
    end
    if fileItem.password == params[:passw1]
      file_path = fileItem.path
      session = GoogleDrive::Session.from_config("config.json")
      file = session.file_by_title([fileItem.user_id.to_s, File.basename(file_path) ])
      body = file.download_to_string
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
      else
        index = name.index(".bin")
        name2 = name[0...index]
       File.open(name2, "wb") { |f| f.write(output.pack('c*'))}
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
    directory =  current_user.id.to_s + "/"
    path = File.join(directory, name + '.bin')

    Dir.chdir("public/data/") do
      File.open(name+ '.bin', "wb") { |f| f.write(output.pack('c*'))}
      session = GoogleDrive::Session.from_config("config.json")
      unless session.collection_by_title(current_user.id.to_s)
        session.root_collection.create_subcollection(current_user.id.to_s)
      end
      file = session.upload_from_file(name+ '.bin', name+ '.bin', convert: false)
      search_folder = session.collection_by_title(current_user.id.to_s)
      search_folder.add(file);
    end

    return path
  end


end
