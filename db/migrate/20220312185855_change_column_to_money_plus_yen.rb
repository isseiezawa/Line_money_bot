class ChangeColumnToMoneyPlusYen < ActiveRecord::Migration[6.1]
  def change
    change_column_null :money, :plus_yen, false, 0
  end
end
