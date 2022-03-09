class CreateMoney < ActiveRecord::Migration[6.1]
  def change
    create_table :money do |t|
      t.integer :yen
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
