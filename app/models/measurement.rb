class Measurement < ActiveRecord::Base
  # Поля:
  # gestational_age - гестационный возраст в неделях
  # measurement_type (HC, BPD, AC, FL)
  # value - значение измерения в мм
  # gender - пол плода (M/F)
  # percentile - рассчитанный процентиль
  
  validates :gestational_age, presence: true, numericality: { greater_than: 0 }
  validates :value, presence: true, numericality: { greater_than: 0 }
end