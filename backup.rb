require 'fileutils'
require 'date'

# Конфигурация
DB_PATH = 'db/intergrowth.db'
BACKUP_DIR = 'db/backups'
KEEP_DAILY = 30  # Хранить ежедневные бэкапы 30 дней
KEEP_MONTHLY = 12 # Хранить месячные бэкапы 12 месяцев

# Создаем папку для бэкапов, если ее нет
FileUtils.mkdir_p(BACKUP_DIR)

# Генерируем имя файла с датой
timestamp = Time.now.strftime("%Y%m%d")
backup_file = "#{BACKUP_DIR}/intergrowth_backup_#{timestamp}.db"

# Копируем базу данных
FileUtils.cp(DB_PATH, backup_file)
puts "Created daily backup: #{backup_file}"

# Если сегодня первое число месяца - создаем месячный бэкап
if Date.today.day == 1
  monthly_backup = "#{BACKUP_DIR}/intergrowth_monthly_#{Date.today.strftime('%Y%m')}.db"
  FileUtils.cp(DB_PATH, monthly_backup)
  puts "Created monthly backup: #{monthly_backup}"
  
  # Удаляем старые ежедневные бэкапы (оставляем только месячные)
  Dir.glob("#{BACKUP_DIR}/intergrowth_backup_*.db").each do |file|
    File.delete(file)
    puts "Deleted daily backup: #{file}"
  end
end

# Очистка старых месячных бэкапов
monthly_backups = Dir.glob("#{BACKUP_DIR}/intergrowth_monthly_*.db").sort
if monthly_backups.size > KEEP_MONTHLY
  (0...monthly_backups.size - KEEP_MONTHLY).each do |i|
    File.delete(monthly_backups[i])
    puts "Deleted old monthly backup: #{monthly_backups[i]}"
  end
end