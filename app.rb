require 'sinatra'
require 'sinatra/activerecord'
require './app/models/measurement'
require './app/models/newborn'

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

# Точные стандарты INTERGROWTH-21st для девочек
GIRLS_STANDARDS = {
  weight: {
    # Неделя => [3rd, 5th, 10th, 50th, 90th, 95th, 97th]
    33 => [1.20, 1.29, 1.41, 1.86, 2.35, 2.51, 2.61],
    34 => [1.47, 1.55, 1.68, 2.13, 2.64, 2.79, 2.90],
    35 => [1.71, 1.79, 1.92, 2.38, 2.89, 3.05, 3.16],
    36 => [1.92, 2.01, 2.14, 2.60, 3.12, 3.28, 3.39],
    37 => [2.11, 2.20, 2.33, 2.80, 3.32, 3.49, 3.60],
    38 => [2.28, 2.37, 2.50, 2.97, 3.51, 3.67, 3.78],
    39 => [2.42, 2.51, 2.65, 3.13, 3.66, 3.83, 3.94],
    40 => [2.55, 2.64, 2.78, 3.26, 3.80, 3.97, 4.08],
    41 => [2.65, 2.75, 2.89, 3.37, 3.92, 4.09, 4.20],
    42 => [2.74, 2.84, 2.98, 3.46, 4.01, 4.19, 4.30]
  },
  hc: {
    33 => [27.92, 28.26, 28.76, 30.46, 32.24, 32.78, 33.14],
    34 => [28.64, 28.96, 29.44, 31.08, 32.78, 33.30, 33.65],
    35 => [29.28, 29.59, 30.06, 31.64, 33.28, 33.78, 34.12],
    36 => [29.87, 30.17, 30.62, 32.14, 33.74, 34.22, 34.55],
    37 => [30.40, 30.69, 31.13, 32.61, 34.15, 34.62, 34.94],
    38 => [30.88, 31.16, 31.59, 33.03, 34.53, 34.99, 35.30],
    39 => [31.32, 31.59, 32.01, 33.41, 34.88, 35.32, 35.62],
    40 => [31.72, 31.99, 32.39, 33.76, 35.19, 35.63, 35.92],
    41 => [32.08, 32.34, 32.74, 34.08, 35.48, 35.91, 36.19],
    42 => [32.41, 32.67, 33.06, 34.37, 35.74, 36.16, 36.44]
  },
  height: {
    33 => [39.79, 40.28, 41.01, 43.39, 45.70, 46.39, 46.85],
    34 => [41.04, 41.51, 42.22, 44.55, 46.79, 47.46, 47.92],
    35 => [42.14, 42.61, 43.30, 45.57, 47.76, 48.42, 48.86],
    36 => [43.13, 43.58, 44.26, 46.48, 48.62, 49.26, 49.69],
    37 => [44.01, 44.45, 45.11, 47.29, 49.39, 50.02, 50.44],
    38 => [44.79, 45.23, 45.88, 48.01, 50.07, 50.69, 51.10],
    39 => [45.49, 45.92, 46.56, 48.65, 50.68, 51.29, 51.69],
    40 => [46.12, 46.54, 47.17, 49.23, 51.23, 51.82, 52.22],
    41 => [46.68, 47.10, 47.72, 49.75, 51.72, 52.30, 52.70],
    42 => [47.19, 47.60, 48.21, 50.22, 52.15, 52.73, 53.12]
  }
}

# Расчет z-score и процентиля
def calculate_z_score(value, median, variation)
  (value - median) / variation
end

def calculate_percentile(z_score)
  100 * (0.5 * (1 + Math.erf(z_score / Math.sqrt(2))))
end
# Получение медианных значений с учетом дней
def get_median_values(gestational_week, gestational_day, measurement_type, gender)
  standards = gender == 'M' ? BOYS_STANDARDS : GIRLS_STANDARDS
  current_week_values = standards[measurement_type][gestational_week]
  next_week_values = standards[measurement_type][gestational_week + 1] if gestational_week < 42
  
  return nil unless current_week_values
  
  if next_week_values && gestational_day > 0
    # Интерполяция между неделями с учетом дней
    day_fraction = gestational_day.to_f / 7.0
    interpolated_values = current_week_values.each_with_index.map do |value, i|
      value + (next_week_values[i] - value) * day_fraction
    end
    
    {
      median: interpolated_values[3], # 50th percentile
      variation: (interpolated_values[4] - interpolated_values[3]) / 1.28
    }
  else
    {
      median: current_week_values[3], # 50th percentile
      variation: (current_week_values[4] - current_week_values[3]) / 1.28
    }
  end
end

def generate_growth_chart(measurement_type, user_value, gestational_week, gestational_day, gender)
  standards = gender == 'M' ? BOYS_STANDARDS : GIRLS_STANDARDS
  percentiles = [3, 10, 25, 50, 75, 90, 97]
  datasets = []
  
  # Генерация кривых процентилей
  percentiles.each_with_index do |p, idx|
    data_points = (33..42).map do |week|
      standards[measurement_type][week] ? standards[measurement_type][week][idx] : nil
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

  # Добавление точки пользователя с учетом дней
  week_index = gestational_week - 33
  exact_position = week_index + (gestational_day.to_f / 7.0) # Позиция с учетом дней
  
  # Для отображения точки с учетом дней
  datasets << {
    label: "Ваш ребенок",
    data: (0..9).map { |i| i == week_index ? user_value : nil },
    pointBackgroundColor: '#ff0000',
    pointRadius: 8,
    pointHoverRadius: 12,
    pointBorderWidth: 2,
    pointBorderColor: '#ffffff',
    showLine: false,
    xValue: exact_position, # Добавляем точное значение позиции по X
  }

  {
    labels: (33..42).map { |w| "#{w} нед." },
    datasets: datasets,
    exact_position: exact_position # Передаем точную позицию для JS
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
  gender = params[:gender] || 'M'
  
  # Получаем параметры из формы
  height = params[:height].to_f
  weight_grams = params[:weight].to_f  # Получаем вес в граммах
  weight = weight_grams / 1000.0      # Конвертируем в килограммы
  hc = params[:head_circumference].to_f

  # Получаем медианные значения с учетом дней
  weight_values = get_median_values(gestational_week, gestational_day, :weight, gender)
  height_values = get_median_values(gestational_week, gestational_day, :height, gender)
  hc_values = get_median_values(gestational_week, gestational_day, :hc, gender)
  
  # Рассчитываем z-score и процентили
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
    gender: gender,
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
  
  # Генерируем графики с учетом пола
  @height_chart = generate_growth_chart(:height, height, gestational_week, gestational_day, gender)
  @weight_chart = generate_growth_chart(:weight, weight, gestational_week, gestational_day, gender)
  @hc_chart = generate_growth_chart(:hc, hc, gestational_week, gestational_day, gender)
  
  erb :result
end

helpers do
  def physical_development_assessment(weight, weight_percentile, height_percentile)
    # Сначала проверяем условия по весу (приоритетные)
    if weight >= 5000
      { category: "5. Гигантский к сроку гестации", 
        alert: "danger" }
    elsif weight >= 4500
      { category: "4. Чрезмерно крупный к сроку гестации", 
        alert: "danger" }
    elsif weight_percentile >= 97 && height_percentile >= 10
      { category: "3. Высокое, крупный к сроку гестации", 
        alert: "danger" }
    elsif weight_percentile >= 90 && weight_percentile < 97 && height_percentile >= 10
      { category: "2. Выше среднего, крупный к сроку гестации", 
        alert: "warning" }
    elsif weight_percentile >= 10 && weight_percentile < 90
      { category: "1. Среднее", 
        alert: "success" }
    elsif weight_percentile >= 3 && weight_percentile < 10
      # Для пунктов 6 и 7 сначала проверяем вес
      if height_percentile < 10
        { category: "7. Ниже среднего, малый к сроку гестации", 
          alert: "danger" }
      else
        { category: "6. Ниже среднего, маловесный к сроку гестации", 
          alert: "warning" }
      end
    elsif weight_percentile < 3
      # Для пунктов 8 и 9 сначала проверяем вес
      if height_percentile < 10
        { category: "9. Низкое, малый к сроку гестации", 
          alert: "danger" }
      else
        { category: "8. Низкое, маловесный к сроку гестации", 
          alert: "danger" }
      end
    else
      # Запасной вариант (не должен достигатьcя при правильных данных)
      { category: "1. Среднее", 
        alert: "success" }
    end
  end
end



# Маршруты для регистра
get '/registry' do
  begin
  @month = if params[:month]
    # Добавляем "-01" чтобы получить полную дату (первое число месяца)
    Date.strptime(params[:month], "%Y-%m")
  else
    Date.today
  end
rescue ArgumentError => e
  puts "Ошибка парсинга даты: #{e.message}"
  @month = Date.today
end
  @newborns = Newborn.where(birth_date: @month.beginning_of_month..@month.end_of_month)
                     .order(birth_date: :desc)
  erb :registry
end

get '/registry/new' do
  @newborn = Newborn.new
  erb :new_newborn
end

post '/registry' do
  # Преобразуем параметры
  newborn_params = params[:newborn]
  
  # Конвертируем вес и рост в числа
  newborn_params[:birth_weight] = newborn_params[:birth_weight].to_f
  newborn_params[:birth_height] = newborn_params[:birth_height].to_f
  
  # Создаем запись
  @newborn = Newborn.new(newborn_params)
  
  if @newborn.save
    # Логирование успешного сохранения
    puts "Новая запись сохранена: #{@newborn.inspect}"
    redirect '/registry'
  else
    # Логирование ошибок
    puts "Ошибки при сохранении: #{@newborn.errors.full_messages}"
    erb :new_newborn
  end
end


delete '/registry/:id' do
  Newborn.find(params[:id]).destroy
  redirect '/registry'
end


# Показать модальное окно с данными
get '/registry/:id/edit' do
  @newborn = Newborn.find(params[:id])
  erb :_edit_modal, layout: false
end

put '/registry/:id' do
  content_type :json
  
  begin
    # Получаем JSON данные из тела запроса
    request.body.rewind
    json_data = JSON.parse(request.body.read)
    newborn_params = json_data['newborn'] || {}
    
    puts "Полученные параметры: #{newborn_params.inspect}"
    
    @newborn = Newborn.find(params[:id])
    if @newborn.update(newborn_params)
      { success: true }.to_json
    else
      status 422
      { errors: @newborn.errors.full_messages }.to_json
    end
  rescue => e
    puts "Ошибка: #{e.message}"
    status 500
    { error: e.message }.to_json
  end
end