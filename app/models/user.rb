class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :File_Items
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
end
