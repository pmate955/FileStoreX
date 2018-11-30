Rails.application.routes.draw do
  get 'file/upload'
  post 'file/uploadFile'
  get 'user/login'
  get 'user/register'
  devise_for :users, :controllers => { registrations: 'users/registrations' }
  get 'home/index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'home#index'
end
