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

ActiveRecord::Schema.define(:version => 20110413084430) do

  create_table "brands", :force => true do |t|
    t.string   "name"
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

  create_table "products_specification_values", :id => false, :force => true do |t|
    t.integer "product_id"
    t.integer "specification_value_id"
  end

  create_table "requirements", :force => true do |t|
    t.float    "target_score"
    t.float    "weight"
    t.integer  "specification_id"
    t.integer  "usage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "order_by"
    t.integer  "num_result"
    t.integer  "start_index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

