# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

password = ENV.fetch("SEED_PASSWORD", "12345")

{ "staff01" => "Comissão Organizadora", "staff02" => "Comissão Técnica" }.each do |nickname, name|
  User.find_or_create_by!(nickname: nickname) do |user|
    user.name = name
    user.password = password
    user.staff = true
  end
end

15.times do |index|
  number = format("%02d", index + 1)

  User.find_or_create_by!(nickname: "equipe#{number}") do |user|
    user.name = "Equipe #{number}"
    user.password = password
  end
end

Contest.first_or_create!
