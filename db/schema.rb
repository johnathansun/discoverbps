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

ActiveRecord::Schema.define(:version => 20130930002312) do

  create_table "preference_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "sort_order"
    t.boolean  "include_in_dialog_box", :default => true
  end

  create_table "preferences", :force => true do |t|
    t.integer  "preference_category_id"
    t.string   "name"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "sort_order"
  end

  add_index "preferences", ["preference_category_id"], :name => "index_preferences_on_preference_category_id"

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
    t.string   "iep"
    t.string   "primary_language"
    t.text     "session_key"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "sibling_school_name"
    t.integer  "sibling_school_id"
    t.string   "student_1_first_name"
    t.string   "student_1_last_name"
    t.string   "student_1_grade_level"
    t.string   "student_2_first_name"
    t.string   "student_2_last_name"
    t.string   "student_2_grade_level"
    t.string   "student_3_first_name"
    t.string   "student_3_last_name"
    t.string   "student_3_grade_level"
    t.string   "student_4_first_name"
    t.string   "student_4_last_name"
    t.string   "student_4_grade_level"
    t.string   "student_5_first_name"
    t.string   "student_5_last_name"
    t.string   "student_5_grade_level"
  end

  create_table "student_preferences", :id => false, :force => true do |t|
    t.integer "student_id",    :null => false
    t.integer "preference_id", :null => false
  end

  add_index "student_preferences", ["student_id", "preference_id"], :name => "index_student_preferences_on_student_id_and_preference_id", :unique => true

  create_table "students", :force => true do |t|
    t.integer  "user_id"
    t.string   "session_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "grade_level"
    t.string   "street_number"
    t.string   "street_name"
    t.string   "zipcode"
    t.string   "iep"
    t.string   "primary_language"
    t.string   "sibling_school_name"
    t.integer  "sibling_school_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "students", ["session_id"], :name => "index_students_on_session_id"
  add_index "students", ["user_id"], :name => "index_students_on_user_id"

end
