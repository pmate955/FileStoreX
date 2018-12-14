class AddDownloadedNumToFileItem < ActiveRecord::Migration[5.2]
  def change
    add_column :file_items, :downloadedNum, :integer, :default => 0
  end
end
