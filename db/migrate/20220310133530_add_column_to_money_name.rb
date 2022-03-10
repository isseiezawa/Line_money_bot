class AddColumnToMoneyName < ActiveRecord::Migration[6.1]
  def change
    add_column :money, :name, :string
  end
end
