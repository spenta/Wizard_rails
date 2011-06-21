# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110621133928) do

  create_table "affiliation_platforms", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", :force => true do |t|
    t.float    "price"
    t.text     "link"
    t.integer  "affiliation_platform_id"
    t.integer  "retailer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
    t.string   "retailer_product_name"
    t.text     "retailer_small_img_url"
  end

  create_table "product_spec_scores", :force => true do |t|
    t.integer  "product_id"
    t.integer  "specification_id"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "small_img_url"
    t.string   "big_img_url"
    t.integer  "brand_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products_specs_scores", :force => true do |t|
    t.integer  "product_id"
    t.integer  "specification_id"
    t.float    "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products_specs_values", :force => true do |t|
    t.integer  "product_id"
    t.integer  "specification_id"
    t.integer  "specification_value_id"
    t.integer  "source_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requirements", :force => true do |t|
    t.float    "target_score"
    t.float    "weight"
    t.integer  "specification_id"
    t.integer  "usage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "retailers", :force => true do |t|
    t.string   "name"
    t.text     "logo_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "specification_values", :force => true do |t|
    t.string   "name"
    t.float    "score"
    t.integer  "specification_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specifications", :force => true do |t|
    t.string   "name"
    t.string   "specification_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "super_usages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "usage_choices", :force => true do |t|
    t.float    "weight_for_user"
    t.integer  "usage_id"
    t.integer  "user_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_selected"
  end

  create_table "usages", :force => true do |t|
    t.string   "name"
    t.integer  "super_usage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_requests", :force => true do |t|
    t.boolean  "is_complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "user_response"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
