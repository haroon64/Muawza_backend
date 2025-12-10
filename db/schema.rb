# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_12_10_183306) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.decimal "latitude"
    t.decimal "longitude"
    t.bigint "sub_service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_id"], name: "index_addresses_on_sub_service_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "sub_service_id", null: false
    t.bigint "customer_profile_id", null: false
    t.integer "booking_status", default: 0, null: false
    t.date "scheduled_date", null: false
    t.time "scheduled_time", null: false
    t.text "customer_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id"], name: "index_bookings_on_customer_profile_id"
    t.index ["sub_service_id", "scheduled_date", "scheduled_time"], name: "index_bookings_on_sub_service_and_schedule"
    t.index ["sub_service_id"], name: "index_bookings_on_sub_service_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "sub_service_name", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_categories_on_service_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "vendor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sub_service_id", null: false
    t.index ["customer_id", "vendor_id", "sub_service_id"], name: "index_conversations_unique_triplet", unique: true
    t.index ["sub_service_id"], name: "index_conversations_on_sub_service_id"
  end

  create_table "customer_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name", null: false
    t.string "address", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "phone_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gender"
    t.index ["address"], name: "index_customer_profiles_on_address", unique: true
    t.index ["full_name"], name: "index_customer_profiles_on_full_name", unique: true
    t.index ["phone_number"], name: "index_customer_profiles_on_phone_number", unique: true
    t.index ["user_id"], name: "index_customer_profiles_on_user_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "customer_profile_id", null: false
    t.bigint "sub_service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id", "sub_service_id"], name: "index_favourites_on_customer_and_sub_service", unique: true
    t.index ["customer_profile_id"], name: "index_favourites_on_customer_profile_id"
    t.index ["sub_service_id"], name: "index_favourites_on_sub_service_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "conversation_id", null: false
    t.bigint "sender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.string "processor_identifier"
    t.string "transaction_reference"
    t.decimal "amount"
    t.integer "status"
    t.string "method"
    t.decimal "processor_fee"
    t.decimal "net_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "sub_service_id", null: false
    t.bigint "customer_profile_id", null: false
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_profile_id"], name: "index_reviews_on_customer_profile_id"
    t.index ["sub_service_id", "customer_profile_id"], name: "index_reviews_on_sub_service_and_customer"
    t.index ["sub_service_id"], name: "index_reviews_on_sub_service_id"
  end

  create_table "service_areas", force: :cascade do |t|
    t.bigint "sub_service_id", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.decimal "radius_km", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_id"], name: "index_service_areas_on_sub_service_id"
  end

  create_table "service_availabilities", force: :cascade do |t|
    t.bigint "sub_service_id", null: false
    t.date "date", null: false
    t.string "time_slot", null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_id", "date", "time_slot"], name: "index_service_availabilities_on_schedule", unique: true
    t.index ["sub_service_id"], name: "index_service_availabilities_on_sub_service_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "service_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sub_services", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.string "sub_service_name", null: false
    t.text "description", null: false
    t.integer "price", null: false
    t.integer "price_bargain"
    t.boolean "active_status", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_profile_id", null: false
    t.index ["service_id"], name: "index_sub_services_on_service_id"
    t.index ["vendor_profile_id"], name: "index_sub_services_on_vendor_profile_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "full_name", default: "", null: false
    t.string "phone_number"
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number_unique", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vendor_portfolios", force: :cascade do |t|
    t.bigint "vendor_profile_id", null: false
    t.text "work_experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vendor_profile_id"], name: "index_vendor_portfolios_on_vendor_profile_id"
  end

  create_table "vendor_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name", null: false
    t.string "address", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "phone_number", null: false
    t.string "second_phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_vendor_profiles_on_address", unique: true
    t.index ["full_name"], name: "index_vendor_profiles_on_full_name", unique: true
    t.index ["phone_number"], name: "index_vendor_profiles_on_phone_number", unique: true
    t.index ["user_id"], name: "index_vendor_profiles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "sub_services"
  add_foreign_key "bookings", "customer_profiles"
  add_foreign_key "bookings", "sub_services"
  add_foreign_key "categories", "services"
  add_foreign_key "conversations", "sub_services"
  add_foreign_key "customer_profiles", "users"
  add_foreign_key "favourites", "customer_profiles"
  add_foreign_key "favourites", "sub_services"
  add_foreign_key "messages", "conversations"
  add_foreign_key "payments", "bookings"
  add_foreign_key "reviews", "customer_profiles"
  add_foreign_key "reviews", "sub_services"
  add_foreign_key "service_areas", "sub_services"
  add_foreign_key "service_availabilities", "sub_services"
  add_foreign_key "sub_services", "services"
  add_foreign_key "sub_services", "vendor_profiles"
  add_foreign_key "vendor_portfolios", "vendor_profiles"
  add_foreign_key "vendor_profiles", "users"
end
