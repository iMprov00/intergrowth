require 'sinatra'
require 'sinatra/activerecord'
require './app/models/measurement'

set :database, {adapter: "sqlite3", database: "db/inter.db"}  # Настройка подключения к SQLite БД

# Расчет процентиля (упрощенный пример)
def calculate_percentile(gestational_age, value, measurement_type, gender)
  # Здесь должна быть реальная формула из Intergrowth-21
  # Для демо: линейная аппроксимация
  mean = 50 + gestational_age * 2.5
  sd = 5 + gestational_age * 0.2
  
  z_score = (value - mean) / sd
  # Конвертация z-score в процентиль
  percentile = 50 * (1 + Math.erf(z_score / Math.sqrt(2)))
  percentile.round(2)
end

get '/' do
  erb :index
end

post '/calculate' do
  @measurement = Measurement.new(params[:measurement])
  
  if @measurement.valid?
    @measurement.percentile = calculate_percentile(
      @measurement.gestational_age.to_f,
      @measurement.value.to_f,
      @measurement.measurement_type,
      @measurement.gender
    )
    
    # Генерация данных для графика
    @chart_data = generate_chart_data(@measurement)
    
    erb :result
  else
    erb :index
  end
end

def generate_chart_data(measurement)
  percentiles = [3, 10, 25, 50, 75, 90, 97]
  datasets = []
  
  # Генерация кривых процентилей
  percentiles.each do |p|
    data = (20..40).map do |week|
      50 + week * 2.5 + (p - 50) * 0.5 # Демо-формула
    end
    
    datasets << {
      label: "P#{p}",
      data: data,
      borderColor: get_color(p),
      fill: false
    }
  end
  
  # Добавление точки пользователя
  user_data = Array.new(21, nil)
  user_data[measurement.gestational_age.to_i - 20] = measurement.value
  
  datasets << {
    label: "Ваш малыш",
    data: user_data,
    pointBackgroundColor: '#ff0000',
    pointRadius: 8,
    showLine: false
  }
  
  {
    labels: (20..40).map { |week| "#{week} нед." },
    datasets: datasets
  }
end

def get_color(percentile)
  # Возвращает цвет для линии процентиля
  case percentile
  when 50 then '#388e3c'
  when 97, 3 then '#d32f2f'
  else '#1976d2'
  end
end