class CreateFileItems < ActiveRecord::Migration[5.2]
  def change
    create_table :file_items do |t|
      t.string :password
      t.string :path

      t.timestamps
    end
  end
end
