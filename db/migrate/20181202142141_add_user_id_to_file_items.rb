class AddUserIdToFileItems < ActiveRecord::Migration[5.2]
  def change
    add_column :file_items, :user_id, :integer
    add_index :file_items, :user_id
  end
end
