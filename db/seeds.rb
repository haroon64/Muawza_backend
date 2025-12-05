

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
# ===========================
# CLEANING (service_id = 1)
# ===========================
cleaning = [
  "Bathroom Cleaning", "Kitchen Cleaning", "Floor Cleaning", "Deep Cleaning",
  "Sofa Cleaning", "Carpet Cleaning", "Glass Cleaning", "Window Cleaning",
  "Office Cleaning", "Home Full Cleaning", "Water Tank Cleaning",
  "Post Construction Cleaning", "Move-in / Move-out Cleaning",
  "Bedroom Cleaning", "Dusting & Vacuuming", "Mattress Cleaning",
  "Roof Cleaning", "Curtain Cleaning"
]

cleaning.each do |name|
  Category.create!(sub_service_name: name, service_id: 1)
end

puts "✅ Cleaning categories seeded."


# ===========================
# CARPENTER (service_id = 2)
# ===========================



# ===========================
# PLUMBER (service_id = 3)
# ===========================
plumber = [
  "Leak Fixing", "Tap Installation", "Water Motor Repair", "Pipe Fitting",
  "Drain Cleaning", "Bathroom Fitting Repair", "Water Tank Installation",
  "Geyser Installation & Repair", "Toilet Repair", "Shower Repair"
]

plumber.each do |name|
  Category.create!(sub_service_name: name, service_id: 2)
end

puts "✅ Plumber categories seeded."


# ===========================
# ELECTRICIAN (service_id = 4)
# ===========================
electrician = [
  "Wiring Repair", "Fan Installation", "Switchboard Repair",
  "Circuit Breaker Fixing", "Light Installation", "Inverter Repair",
  "Meter Installation", "Generator Wiring", "UPS Installation",
  "Electric Panel Repair"
]

electrician.each do |name|
  Category.create!(sub_service_name: name, service_id: 3)
end

puts "✅ Electrician categories seeded."

carpenter = [
  "Furniture Repair", "Door Installation", "Window Frame Repair",
  "Wooden Partition Work", "Cabinet Making", "Bed Repair",
  "Custom Furniture", "Wardrobe Repair", "Kitchen Cabinets Installation",
  "Wood Polishing"
]

carpenter.each do |name|
  Category.create!(sub_service_name: name, service_id: 4)
end

puts "✅ Carpenter categories seeded."


# ===========================
# AC REPAIR (service_id = 5)
# ===========================
ac_repair = [
  "AC Gas Filling", "AC Installation", "AC Uninstallation",
  "AC Cooling Issue Fix", "AC Servicing / Cleaning",
  "AC Water Leakage Repair", "AC Compressor Repair",
  "AC PCB Repair", "Split AC Service", "Window AC Service"
]

ac_repair.each do |name|
  Category.create!(sub_service_name: name, service_id: 5)
end

puts "✅ AC Repair categories seeded."


# ===========================
# PAINTING (service_id = 6)
# ===========================
painting = [
  "Interior Wall Painting", "Exterior Wall Painting", "Ceiling Painting",
  "Door & Window Painting", "Metal Painting", "Wooden Surface Painting",
  "Wall Putty & Plaster", "Texture Painting", "Wallpaper Installation",
  "Waterproof Wall Coating"
]

painting.each do |name|
  Category.create!(sub_service_name: name, service_id: 6)
end

puts "🎨 Painting categories seeded."


# ===========================
# GARDENER (service_id = 7)
# ===========================
gardener = [
  "Lawn Mowing", "Garden Cleanup", "Plant Trimming", "Tree Pruning",
  "Flower Bed Maintenance", "Garden Installation", "Weed Removal",
  "Soil Fertilization", "Plant Treatment (Pesticides)", "Hedge Trimming"
]

gardener.each do |name|
  Category.create!(sub_service_name: name, service_id: 7)
end

puts "🌿 Gardener categories seeded."


# ===========================
# CAR MECHANIC (service_id = 8)
# ===========================
car_mechanic = [
  "Engine Repair", "Oil Change", "Brake Service", "AC Repair",
  "Battery Replacement", "Suspension Repair", "Car Scanning",
  "Clutch Repair", "Electrical Fault Fixing", "Tyre Replacement"
]

car_mechanic.each do |name|
  Category.create!(sub_service_name: name, service_id: 8)
end

puts "🚗 Car Mechanic categories seeded."


# ===========================
# CAR WASH (service_id = 10)
# ===========================
car_wash = [
  "Basic Exterior Wash", "Full Body Wash", "Interior Vacuuming",
  "Full Interior Detailing", "Engine Cleaning", "Pressure Wash",
  "Foam Wash", "Wax & Polish", "Ceramic Coating", "Underbody Wash"
]

car_wash.each do |name|
  Category.create!(sub_service_name: name, service_id: 10)
end

puts "🚙 Car Wash categories seeded."


puts "🎉 ALL CATEGORIES SEEDED SUCCESSFULLY!"
