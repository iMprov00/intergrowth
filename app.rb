require 'sinatra'
require 'sinatra/activerecord'
require './app/models/measurement'

# Настройка БД
set :database, { adapter: "sqlite3", database: "db/inter.db" }

# Обработчик главной страницы
get '/' do
  erb :index
end

# Методы расчета процентилей (демо-версии)
def calculate_height_percentile(age_days, height, gender)
  # Демо-формула (замените на реальную из Intergrowth-21)
  mean = gender == 'M' ? 45.0 + age_days * 0.05 : 44.0 + age_days * 0.048
  sd = 2.5 + age_days * 0.002
  z_score = (height - mean) / sd
  (50 * (1 + Math.erf(z_score / Math.sqrt(2)))).round(2)
end

def calculate_weight_percentile(age_days, weight, gender)
  # Демо-формула (замените на реальную из Intergrowth-21)
  mean = gender == 'M' ? 3.0 + age_days * 0.005 : 2.9 + age_days * 0.0048
  sd = 0.5 + age_days * 0.0005
  z_score = (weight - mean) / sd
  (50 * (1 + Math.erf(z_score / Math.sqrt(2)))).round(2)
end

def calculate_hc_percentile(age_days, hc, gender)
  # Демо-формула (замените на реальную из Intergrowth-21)
  mean = gender == 'M' ? 32.0 + age_days * 0.03 : 31.0 + age_days * 0.029
  sd = 1.2 + age_days * 0.001
  z_score = (hc - mean) / sd
  (50 * (1 + Math.erf(z_score / Math.sqrt(2)))).round(2)
end

def calculate_percentiles(measurement)
  age_days = measurement.gestational_age.to_f
  
  {
    height: calculate_height_percentile(age_days, measurement.height_cm, measurement.gender),
    weight: calculate_weight_percentile(age_days, measurement.weight_kg, measurement.gender),
    hc: calculate_hc_percentile(age_days, measurement.head_circumference_cm, measurement.gender)
  }
end

def get_color(percentile)
  case percentile
  when 50 then '#388e3c' # зеленый для медианы
  when 97, 3 then '#d32f2f' # красный для крайних
  else '#1976d2' # синий для остальных
  end
end

def generate_growth_chart(measurement_type, gender, user_value = nil, gestational_age)
  percentiles = [3, 10, 25, 50, 75, 90, 97]
  datasets = []
  
  percentiles.each do |p|
    data = (140..280).step(7).map do |day|
      case measurement_type
      when :height
        (gender == 'M' ? 45.0 + day * 0.05 + (p - 50) * 0.03 : 44.0 + day * 0.048 + (p - 50) * 0.028).round(2)
      when :weight
        (gender == 'M' ? 3.0 + day * 0.005 + (p - 50) * 0.0008 : 2.9 + day * 0.0048 + (p - 50) * 0.00075).round(3)
      when :hc
        (gender == 'M' ? 32.0 + day * 0.03 + (p - 50) * 0.005 : 31.0 + day * 0.029 + (p - 50) * 0.004).round(2)
      end
    end
    
    datasets << {
      label: "P#{p}",
      data: data,
      borderColor: get_color(p),
      fill: false,
      borderWidth: (p == 50 ? 3 : 1)
    }
  end

  # Добавляем точку пользователя
  if user_value
    user_data = Array.new((280-140)/7 + 1, nil)
    week_index = ((gestational_age - 140)/7).round
    user_data[week_index] = user_value
    
    datasets << {
      label: "Ваш ребенок",
      data: user_data,
      pointBackgroundColor: '#ff0000',
      pointRadius: 8,
      showLine: false
    }
  end

  {
    labels: (140..280).step(7).map { |d| "#{(d/7.0).round(1)} нед." },
    datasets: datasets
  }
end

post '/calculate' do
  @measurement = Measurement.new(
    gestational_age: params[:gestational_age].to_i,
    gender: params[:gender],
    height: (params[:height].to_f * 10).round, # см -> мм для хранения
    weight: (params[:weight].to_f * 1000).round, # кг -> граммы
    head_circumference: (params[:head_circumference].to_f * 10).round # см -> мм
  )
  
  if @measurement.valid?
    percentiles = calculate_percentiles(@measurement)
    @measurement.height_percentile = percentiles[:height]
    @measurement.weight_percentile = percentiles[:weight]
    @measurement.hc_percentile = percentiles[:hc]
    
    @height_chart = generate_growth_chart(:height, @measurement.gender, @measurement.height_cm, @measurement.gestational_age)
    @weight_chart = generate_growth_chart(:weight, @measurement.gender, @measurement.weight_kg, @measurement.gestational_age)
    @hc_chart = generate_growth_chart(:hc, @measurement.gender, @measurement.head_circumference_cm, @measurement.gestational_age)
    
    erb :result
  else
    @errors = @measurement.errors.full_messages
    erb :index
  end
end