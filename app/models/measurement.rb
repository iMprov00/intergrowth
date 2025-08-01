class Measurement < ActiveRecord::Base
  validates :gestational_weeks, presence: true, numericality: { in: 33..42 }
  validates :gestational_days, presence: true, numericality: { in: 0..6 }
  validates :gender, presence: true, inclusion: { in: %w[M] } # Только мальчики
  validates :height, :weight, :head_circumference, numericality: { greater_than: 0 }
  
  def gestational_age
    "#{gestational_weeks}+#{gestational_days}"
  end
end