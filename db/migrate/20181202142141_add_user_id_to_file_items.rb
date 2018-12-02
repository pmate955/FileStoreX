class AddUserIdToFileItems < ActiveRecord::Migration[5.2]
  def change
    add_column :File_Items, :user_id, :integer
    add_index :File_Items, :user_id
  end
end
