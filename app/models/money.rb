class Money < ApplicationRecord
  belongs_to :user

  scope :year_month_day_serch, -> { group("EXTRACT(year FROM created_at), EXTRACT(month FROM created_at), EXTRACT(day FROM created_at)").sum(:yen).sort.reverse.to_h }
  scope :year_month_serch, -> { group("EXTRACT(year FROM created_at), EXTRACT(month FROM created_at)").sum(:yen).sort.reverse.to_h }
end
