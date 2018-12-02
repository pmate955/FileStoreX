class AddStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :File_Items, :status, :string, :null => false, :default => 'Uploaded'
  end
end
