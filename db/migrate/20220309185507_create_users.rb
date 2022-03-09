class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.integer :line_id
      t.string :name

      t.timestamps
    end
  end
end
