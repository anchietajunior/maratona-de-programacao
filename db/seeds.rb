# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.find_or_create_by!(nickname: "staff01") do |user|
  user.name = "Comissão Organizadora"
  user.password = "12345"
  user.staff = true
end

User.find_or_create_by!(nickname: "equipe01") do |user|
  user.name = "Equipe 01"
  user.password = "12345"
  user.staff = false
end
