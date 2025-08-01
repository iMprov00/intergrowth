class Newborn < ActiveRecord::Base
  validates :last_name, :first_name, :birth_date, :birth_weight, :birth_height, presence: true
  validates :gender, inclusion: { in: %w[M F] }
 
  
  def full_name
    "#{last_name} #{first_name} #{patronymic}".strip
  end
  
  def bed_days
    return nil unless admission_date && discharge_date
    (discharge_date - admission_date).to_i
  end

    validates :apgar_1, :apgar_5, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :feeding, inclusion: { in: ['Грудное', 'Смешанное', 'Искусственное'] }, allow_nil: true
  validates :delivery_method, inclusion: { in: ['КС', 'Сам.'] }, allow_nil: true
  
  def apgar
    "#{apgar_1}/#{apgar_5}" if apgar_1 && apgar_5
  end

end