class AddColumnToMoneysPlusYen < ActiveRecord::Migration[6.1]
  def change
    add_column :money, :plus_yen, :integer
  end
end
