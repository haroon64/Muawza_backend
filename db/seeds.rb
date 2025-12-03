

# Seed services with icons
services_data = [
  { name: "Cleaning", icon: 'cleaning.png' },
  { name: "Plumber", icon: "plumber.png" },
  { name: "Electrician", icon: "electrician.png" },
  { name: "Carpenter", icon: "carpenter.png" },
  { name: "AC Repair", icon: "maintenance.png" },
  { name: "Painting", icon: "painter.png" },
  { name: "Gardner", icon: "person.png" },
  { name: "Car Mechanic", icon: "mechanic.png" },
{ name: "Gardner", icon: "person.png" },
  { name: "Car wash", icon: "car-service.png" },
]

services_data.each do |data|
  service = Service.create!(service_name: data[:name])
  file_path = Rails.root.join("db", "seeds", "images", data[:icon])
  service.icon.attach(io: File.open(file_path), filename: data[:icon])
end

puts "Seeded #{Service.count} services with icons!"
