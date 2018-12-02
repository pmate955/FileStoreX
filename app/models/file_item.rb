class FileItem < ApplicationRecord
  belongs_to :User, optional: true
end
