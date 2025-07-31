require 'sinatra'
require 'sinatra/activerecord'
require './app/models/measurement'

# Настройка БД
set :database, { adapter: "sqlite3", database: "db/intergrowth.db" }

# Точные стандарты INTERGROWTH-21st для мальчиков
BOYS_STANDARDS = {
  weight: {
    # Неделя => [3rd, 5th, 10th, 50th, 90th, 95th, 97th]
    33 => [1.18, 1.28, 1.43, 1.95, 2.52, 2.70, 2.82],
    34 => [1.45, 1.55, 1.71, 2.22, 2.79, 2.96, 3.08],
    35 => [1.70, 1.80, 1.95, 2.47, 3.03, 3.20, 3.32],
    36 => [1.93, 2.03, 2.18, 2.69, 3.25, 3.42, 3.54],
    37 => [2.13, 2.24, 2.38, 2.89, 3.45, 3.62, 3.74],
    38 => [2.32, 2.42, 2.57, 3.07, 3.63, 3.80, 3.92],
    39 => [2.49, 2.59, 2.73, 3.24, 3.79, 3.96, 4.08],
    40 => [2.63, 2.73, 2.88, 3.38, 3.94, 4.11, 4.22],
    41 => [2.76, 2.86, 3.01, 3.51, 4.06, 4.23, 4.35],
    42 => [2.88, 2.98, 3.12, 3.62, 4.17, 4.34, 4.46]
  },
  hc: {
    33 => [28.24, 28.59, 29.11, 30.88, 32.70, 33.25, 33.62],
    34 => [28.93, 29.26, 29.76, 31.47, 33.23, 33.76, 34.11],
    35 => [29.56, 29.88, 30.37, 32.02, 33.73, 34.24, 34.58],
    36 => [30.15, 30.46, 30.93, 32.53, 34.19, 34.69, 35.02],
    37 => [30.69, 31.00, 31.46, 33.02, 34.63, 35.11, 35.43],
    38 => [31.21, 31.51, 31.95, 33.47, 35.04, 35.51, 35.83],
    39 => [31.69, 31.98, 32.42, 33.90, 35.44, 35.90, 36.20],
    40 => [32.15, 32.43, 32.86, 34.31, 35.81, 36.26, 36.56],
    41 => [32.58, 32.86, 33.28, 34.70, 36.17, 36.61, 36.91],
    42 => [32.99, 33.27, 33.68, 35.07, 36.52, 36.95, 37.24]
  },
  height: {
    33 => [39.69, 40.25, 41.09, 43.81, 46.55, 47.39, 47.97],
    34 => [41.05, 41.59, 42.38, 44.98, 47.59, 48.39, 48.94],
    35 => [42.26, 42.78, 43.54, 46.03, 48.53, 49.30, 49.82],
    36 => [43.36, 43.85, 44.58, 46.97, 49.38, 50.12, 50.62],
    37 => [44.34, 44.82, 45.52, 47.82, 50.14, 50.85, 51.34],
    38 => [45.22, 45.69, 46.37, 48.59, 50.83, 51.52, 51.99],
    39 => [46.02, 46.47, 47.13, 49.29, 51.46, 52.13, 52.59],
    40 => [46.75, 47.19, 47.83, 49.92, 52.03, 52.68, 53.13],
    41 => [47.41, 47.84, 48.46, 50.50, 52.56, 53.19, 53.62],
    42 => [48.01, 48.43, 49.04, 51.03, 53.03, 53.65, 54.07]
  }
}

# Расчет z-score и процентиля
def calculate_z_score(value, median, variation)
  (value - median) / variation
end

def calculate_percentile(z_score)
  100 * (0.5 * (1 + Math.erf(z_score / Math.sqrt(2))))
end

# Получение медианных значений
def get_median_values(gestational_week, measurement_type)
  standards = BOYS_STANDARDS[measurement_type][gestational_week]
  return nil unless standards
  
  {
    median: standards[3], # 50th percentile
    variation: (standards[4] - standards[3]) / 1.28 # SD for 90th percentile (z=1.28)
  }
end

# Генерация данных для графиков
def generate_growth_chart(measurement_type, user_value, gestational_week)
  standards = BOYS_STANDARDS[measurement_type]
  percentiles = [3, 10, 25, 50, 75, 90, 97]
  z_scores = [-1.88, -1.28, -0.67, 0, 0.67, 1.28, 1.88]
  datasets = []
  
  # Генерация кривых процентилей
  percentiles.each_with_index do |p, idx|
    data_points = (33..42).map do |week|
      standards[week] ? standards[week][idx] : nil
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
  user_data = Array.new(10, nil) # 33-42 weeks = 10 points
  week_index = gestational_week - 33
  user_data[week_index] = user_value if week_index.between?(0, 9)
  
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
    labels: (33..42).map { |w| "#{w} нед." },
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
    @title = "Калькулятор роста плода INTERGROWTH-21st"
  erb :index
end

post '/calculate' do
  gestational_week = params[:gestational_weeks].to_i
  gestational_day = params[:gestational_days].to_i
  
  # Получаем медианные значения
  weight_values = get_median_values(gestational_week, :weight)
  height_values = get_median_values(gestational_week, :height)
  hc_values = get_median_values(gestational_week, :hc)
  
  # Рассчитываем z-score и процентили
  height = params[:height].to_f
  weight = params[:weight].to_f
  hc = params[:head_circumference].to_f
  
  height_z = calculate_z_score(height, height_values[:median], height_values[:variation])
  weight_z = calculate_z_score(weight, weight_values[:median], weight_values[:variation])
  hc_z = calculate_z_score(hc, hc_values[:median], hc_values[:variation])
  
  height_percentile = calculate_percentile(height_z)
  weight_percentile = calculate_percentile(weight_z)
  hc_percentile = calculate_percentile(hc_z)
  
  # Сохраняем измерения
  @measurement = Measurement.new(
    gestational_weeks: gestational_week,
    gestational_days: gestational_day,
    gender: 'M', # Только для мальчиков
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
  @height_chart = generate_growth_chart(:height, height, gestational_week)
  @weight_chart = generate_growth_chart(:weight, weight, gestational_week)
  @hc_chart = generate_growth_chart(:hc, hc, gestational_week)
  
  erb :result
end

helpers do
  def physical_development_assessment(weight, weight_percentile, height_percentile)
    if weight >= 5000
      { category: "5. Чрезмерно крупный к сроку гестации", 
        message: "Вес выше 5000 кг!", 
        alert: "danger" }
    elsif weight >= 4500
      { category: "4. Крупный к сроку гестации", 
        message: "Вес выше 4500 кг!", 
        alert: "danger" }
    elsif weight_percentile >= 97 && height_percentile >= 10
      { category: "3. Крупный к сроку гестации", 
        alert: "danger" }
    elsif weight_percentile >= 90 && weight_percentile < 97 && height_percentile >= 10
      { category: "2. Выше среднего", 
        alert: "warning" }
    elsif weight_percentile >= 10 && weight_percentile < 90 && height_percentile >= 10
      { category: "1. Среднее", 
        alert: "success" }
    elsif weight_percentile >= 3 && weight_percentile < 10 && height_percentile >= 10
      { category: "6. Ниже среднего", 
        alert: "warning" }
    elsif weight_percentile >= 3 && weight_percentile < 10 && height_percentile < 10
      { category: "7. Малый к сроку гестации", 
        alert: "danger" }
    elsif weight_percentile < 3 && height_percentile >= 10
      { category: "8. Маловесный к сроку гестации", 
        alert: "danger" }
    else
      { category: "9. Малый к сроку гестации", 
        alert: "danger" }
    end
  end
end