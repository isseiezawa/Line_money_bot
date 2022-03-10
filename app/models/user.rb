class User < ApplicationRecord
  has_many :money

  enum name_status: { no_name: 0, catch_name: 1, exist_name: 2 }
end
