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

ActiveRecord::Schema.define(:version => 20120118103507) do

  create_table "aboutus", :force => true do |t|
    t.text     "description"
    t.integer  "locale_id",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "academic_years", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", :force => true do |t|
    t.string   "name"
    t.integer  "question_id"
    t.integer  "is_answer"
    t.integer  "sort_order"
    t.integer  "image_id"
    t.string   "fb_sequence"
    t.string   "match_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.integer  "course_id"
    t.integer  "academic_year_id"
    t.integer  "section_id"
    t.integer  "department_id"
    t.integer  "semester_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_titles", :force => true do |t|
    t.string   "name"
    t.integer  "category_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_types", :force => true do |t|
    t.string   "title"
    t.integer  "organization_id"
    t.integer  "sort_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categoryexams", :force => true do |t|
    t.integer  "category_id"
    t.integer  "exam_id"
    t.integer  "examtype_id"
    t.string   "currentyear"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categoryexamusers", :force => true do |t|
    t.integer  "categoryexam_id"
    t.integer  "categoryuser_id"
    t.integer  "is_confirmed"
    t.integer  "has_attended",    :default => 0
    t.integer  "attempt"
    t.datetime "exam_date"
    t.string   "question_set"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "time_hour",       :default => 0
    t.integer  "time_min",        :default => 0
    t.integer  "has_evaluated",   :default => 0
    t.integer  "need_evaluation", :default => 0
  end

  create_table "categorysubjects", :force => true do |t|
    t.integer  "category_id"
    t.integer  "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categorysubjects", ["category_id", "subject_id"], :name => "by_category_and_subject", :unique => true

  create_table "categoryusers", :force => true do |t|
    t.integer  "category_id"
    t.integer  "user_id"
    t.string   "currentyear"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clientinfos", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.text     "content"
    t.string   "section_id"
    t.text     "help_content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content_de"
  end

  create_table "evaluate_exams", :force => true do |t|
    t.integer  "exam_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "categoryexam_id"
  end

  create_table "evaluations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.string   "fb_sequence"
    t.integer  "sort_order"
    t.string   "answer_name"
    t.boolean  "has_attended",       :default => false
    t.float    "question_mark"
    t.float    "answer_mark"
    t.integer  "attempt"
    t.integer  "categoryexam_id"
    t.integer  "categoryuser_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "descriptive_answer"
    t.integer  "evaluate",           :default => 0
  end

  create_table "exam_results", :force => true do |t|
    t.integer  "categoryexam_id"
    t.integer  "categoryuser_id"
    t.float    "score"
    t.string   "status"
    t.integer  "attempt"
    t.float    "total_mark"
    t.float    "percent"
    t.string   "examname"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "result_pending",  :default => 0
  end

  create_table "examquestions", :force => true do |t|
    t.integer  "exam_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "examquestions", ["exam_id", "question_id"], :name => "by_exam_and_question", :unique => true

  create_table "exams", :force => true do |t|
    t.string   "name"
    t.string   "exam_code"
    t.datetime "exam_date"
    t.time     "total_time"
    t.text     "instruction"
    t.string   "exam_type"
    t.integer  "total_mark"
    t.string   "subject"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.time     "examstart_time"
    t.integer  "time_hour",         :default => 0
    t.integer  "time_min",          :default => 0
    t.integer  "start_exam",        :default => 0
    t.integer  "manual_evaluation", :default => 0
    t.integer  "pass_mark"
  end

  create_table "examtypes", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedback_answers", :force => true do |t|
    t.integer  "feedback_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.text     "description"
    t.integer  "question_type_id"
    t.integer  "sort_order"
    t.boolean  "is_published"
    t.boolean  "is_shared"
    t.integer  "user_id"
    t.integer  "subject_id"
    t.integer  "image_id"
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "categorysubject_id"
    t.float    "mark"
    t.integer  "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "randomquestions", :force => true do |t|
    t.integer  "exam_id"
    t.string   "question_set"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.string   "authorizable_type"
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", :force => true do |t|
    t.string   "name"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.boolean  "allow_examinee_registration", :default => false
    t.boolean  "confirm_exam",                :default => false
    t.string   "datetime_format"
    t.string   "locale"
    t.integer  "organization_id"
    t.integer  "examineeApprove",             :default => 0
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_questions", :force => true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_questions", ["question_id", "user_id"], :name => "by_question_and_user", :unique => true

  create_table "subjects", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subjects", ["name", "category_id"], :name => "by_name_and_category", :unique => true

  create_table "subjectusers", :force => true do |t|
    t.integer  "subject_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "categorysubject_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login",              :default => "",    :null => false
    t.string   "email",              :default => "",    :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",  :default => "",    :null => false
    t.string   "perishable_token",   :default => "",    :null => false
    t.integer  "login_count",        :default => 0,     :null => false
    t.string   "language",           :default => "en"
    t.integer  "failed_login_count", :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.integer  "role_id"
    t.boolean  "confirmed",          :default => false
    t.integer  "is_approved",        :default => 0
    t.integer  "is_temp_examinee",   :default => 0,     :null => false
    t.boolean  "active",             :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_registered",      :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token", :unique => true

end
