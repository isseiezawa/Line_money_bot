class ChangeColumnToMoneysYen < ActiveRecord::Migration[6.1]
  def change
    change_column_null :money, :yen, false, 0
  end
end
