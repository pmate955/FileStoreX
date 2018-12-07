class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|
      t.string :dateTime
      t.integer :visits
      t.integer :userVisit
      t.integer :newUsers

      t.timestamps
    end
  end
end
