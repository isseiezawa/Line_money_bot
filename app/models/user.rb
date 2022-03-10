class User < ApplicationRecord
  has_many :moneys, dependent: :destroy

  enum name_status: { no_name: 0, catch_name: 1, exist_name: 2 }
  enum money_status: { input_money: 0,  }
end
