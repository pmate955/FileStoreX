Rails.application.routes.draw do
  get 'file/upload'
  post 'file/uploadFile'
  match 'downloadFile', to: 'file#downloadFile', as: 'download', via: :get
  get 'file/uploadUserFile'
  post 'file/uploadUserFilePost'
  post 'file/deleteFile'
  post 'file/downloadEnc'
  get 'file/show'
  post 'file/tryPass'
  post 'file/searchFile'
  get 'file/not_found'
  get 'home/set_locale'
  get 'users/home/set_locale', to: 'home#set_locale'
  get 'user/login'
  get 'user/register'
  get 'user/showFiles'
  devise_for :users, :controllers => { registrations: 'users/registrations', sessions: 'users/sessions' }
  get 'home/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'home#index'
end
