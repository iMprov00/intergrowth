require 'sinatra'
require 'sinatra/activerecord'
require 'csv'
require './app/models/measurement'

# Настройка БД
set :database, { adapter: "sqlite3", database: "db/intergrowth.db" }

# Загрузка реальных данных INTERGROWTH-21st
BOYS_DATA = CSV.read('data/boys_growth_data.csv', headers: true, converters: :numeric)
GIRLS_DATA = CSV.read('data/girls_growth_data.csv', headers: true, converters: :numeric)

# Точные формулы расчета z-score по INTERGROWTH-21st
def calculate_z_score(value, median, variation)
  (value - median) / variation
end

# Прямой расчет процентиля из z-score
def calculate_percentile(z_score)
  100 * (0.5 * (1 + Math.erf(z_score / Math.sqrt(2))))
end

# Получение медианных значений по гестационному возрасту
def get_median_values(gestational_days, gender)
  data = gender == 'M' ? BOYS_DATA : GIRLS_DATA
  row = data.find { |r| r['gestational_days'].to_i == gestational_days }
  
  {
    weight: row['weight_median'].to_f,
    height: row['height_median'].to_f,
    hc: row['hc_median'].to_f,
    weight_variation: row['weight_variation'].to_f,
    height_variation: row['height_variation'].to_f,
    hc_variation: row['hc_variation'].to_f
  }
end

# Генерация данных для графиков
def generate_growth_chart(measurement_type, gender, user_value, gestational_days)
  percentiles = [3, 10, 25, 50, 75, 90, 97]
  z_scores = [-1.88, -1.28, -0.67, 0, 0.67, 1.28, 1.88]
  datasets = []
  
  # Генерация кривых процентилей
  percentiles.each_with_index do |p, idx|
    data_points = (168..294).step(7).map do |days|
      values = get_median_values(days, gender)
      median = values[measurement_type]
      variation = values["#{measurement_type}_variation".to_sym]
      median + variation * z_scores[idx]
    end
    
    datasets << {
      label: "P#{p}",
      data: data_points,
      borderColor: get_color(p),
      fill: false,
      borderWidth: (p == 50 ? 3 : 1),
      pointRadius: 0
    }
  end

  # Добавление точки пользователя
  user_data = Array.new((294-168)/7 + 1, nil)
  week_index = ((gestational_days - 168)/7).round
  user_data[week_index] = user_value
  
  datasets << {
    label: "Ваш ребенок",
    data: user_data,
    pointBackgroundColor: '#ff0000',
    pointRadius: 8,
    pointHoverRadius: 12,
    pointBorderWidth: 2,
    pointBorderColor: '#ffffff',
    showLine: false
  }

  {
    labels: (168..294).step(7).map { |d| "#{(d/7.0).round(1)} нед." },
    datasets: datasets
  }
end

def get_color(percentile)
  case percentile
  when 50 then '#388e3c' # зеленый
  when 3, 97 then '#d32f2f' # красный
  when 10, 90 then '#1976d2' # синий
  else '#9c27b0' # фиолетовый
  end
end

# Маршруты
get '/' do
  erb :index
end

post '/calculate' do
  gestational_weeks = params[:gestational_weeks].to_i
  gestational_days = params[:gestational_days].to_i
  gestational_days_total = gestational_weeks * 7 + gestational_days
  
  # Получаем медианные значения
  median_values = get_median_values(gestational_days_total, params[:gender])
  
  # Рассчитываем z-score и процентили
  height = params[:height].to_f
  weight = params[:weight].to_f
  hc = params[:head_circumference].to_f
  
  height_z = calculate_z_score(height, median_values[:height], median_values[:height_variation])
  weight_z = calculate_z_score(weight, median_values[:weight], median_values[:weight_variation])
  hc_z = calculate_z_score(hc, median_values[:hc], median_values[:hc_variation])
  
  height_percentile = calculate_percentile(height_z)
  weight_percentile = calculate_percentile(weight_z)
  hc_percentile = calculate_percentile(hc_z)
  
  # Сохраняем измерения
  @measurement = Measurement.new(
    gestational_weeks: gestational_weeks,
    gestational_days: gestational_days,
    gender: params[:gender],
    height: height,
    weight: weight,
    head_circumference: hc,
    height_z: height_z,
    weight_z: weight_z,
    hc_z: hc_z,
    height_percentile: height_percentile,
    weight_percentile: weight_percentile,
    hc_percentile: hc_percentile
  )
  
  # Генерируем графики
  @height_chart = generate_growth_chart(:height, params[:gender], height, gestational_days_total)
  @weight_chart = generate_growth_chart(:weight, params[:gender], weight, gestational_days_total)
  @hc_chart = generate_growth_chart(:hc, params[:gender], hc, gestational_days_total)
  
  erb :result
end