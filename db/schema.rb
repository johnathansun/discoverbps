# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130929025005) do

  create_table "schools", :force => true do |t|
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.text     "api_basic_info"
    t.text     "api_awards"
    t.text     "api_calendar"
    t.text     "api_description"
    t.text     "api_extra_curricular"
    t.text     "api_facilities"
    t.text     "api_grades"
    t.text     "api_hours"
    t.text     "api_languages"
    t.text     "api_partners"
    t.text     "api_photos"
    t.string   "name"
    t.integer  "bps_id"
    t.string   "slug"
  end

  add_index "schools", ["slug"], :name => "index_schools_on_slug", :unique => true

  create_table "searches", :force => true do |t|
    t.string   "street_number"
    t.string   "street_name"
    t.string   "zipcode"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "grade_level"
    t.string   "iep"
    t.string   "language"
    t.text     "session_key"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

end
