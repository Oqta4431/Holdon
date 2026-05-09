# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find(4)

10.times do
  item = Item.create!(
    user: user,
    name: Faker::Commerce.product_name,
    price:Faker::Commerce.price(range: 100..50000).to_i
  )

  item.create_judgement!(purchase_status: :considering)

  item.judgement.update!(
    decided_at: 1.week.ago,
    purchase_status: [ :purchased, :skipped].sample
  )
end