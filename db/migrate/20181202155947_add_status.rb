class AddStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :file_items, :status, :string, :null => false, :default => 'Uploaded'
  end
end
