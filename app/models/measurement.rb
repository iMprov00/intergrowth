class Measurement < ActiveRecord::Base
  # Конвертация единиц измерения
  def height_cm = height.to_f / 10.0
  def weight_kg = weight.to_f / 1000.0
  def head_circumference_cm = head_circumference.to_f / 10.0
end