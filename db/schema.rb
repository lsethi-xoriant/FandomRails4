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

ActiveRecord::Schema.define(:version => 20140827144323) do

  create_table "answers", :force => true do |t|
    t.integer  "quiz_id",                                     :null => false
    t.string   "text",                                        :null => false
    t.boolean  "correct"
    t.boolean  "remove_answer",            :default => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "call_to_action_id"
    t.string   "media_image_file_name"
    t.string   "media_image_content_type"
    t.integer  "media_image_file_size"
    t.datetime "media_image_updated_at"
    t.text     "media_data"
    t.string   "media_type"
    t.boolean  "blocking",                 :default => false
  end

  add_index "answers", ["call_to_action_id"], :name => "index_answers_on_call_to_action_id"
  add_index "answers", ["quiz_id"], :name => "index_answers_on_quiz_id"

  create_table "authentications", :force => true do |t|
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.string   "provider"
    t.string   "avatar"
    t.datetime "oauth_expires_at"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "new"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "call_to_action_tags", :force => true do |t|
    t.integer  "call_to_action_id"
    t.integer  "tag_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "call_to_actions", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "media_type"
    t.boolean  "enable_disqus",            :default => false
    t.datetime "activated_at"
    t.string   "secondary_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "slug"
    t.boolean  "user_generated"
    t.string   "media_image_file_name"
    t.string   "media_image_content_type"
    t.integer  "media_image_file_size"
    t.datetime "media_image_updated_at"
    t.text     "media_data"
    t.integer  "releasing_file_id"
    t.boolean  "approved"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
  end

  add_index "call_to_actions", ["name"], :name => "index_call_to_actions_on_name", :unique => true
  add_index "call_to_actions", ["slug"], :name => "index_call_to_actions_on_slug"

  create_table "checks", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "comments", :force => true do |t|
    t.boolean  "must_be_approved", :default => false
    t.string   "title"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "contest_periodicities", :force => true do |t|
    t.string   "title",               :null => false
    t.integer  "custom_periodicity"
    t.integer  "periodicity_type_id"
    t.integer  "contest_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "contest_points", :force => true do |t|
    t.integer  "points"
    t.integer  "user_id"
    t.integer  "contest_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contest_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "contest_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contests", :force => true do |t|
    t.boolean  "generated",       :default => false
    t.boolean  "boolean",         :default => false
    t.string   "title",                              :null => false
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "property_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "conversion_rate", :default => 1
  end

  create_table "downloads", :force => true do |t|
    t.string   "title",                   :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "events", :force => true do |t|
    t.string  "session_id"
    t.integer "pid"
    t.string  "message"
    t.string  "request_uri"
    t.string  "file_name"
    t.string  "method_name"
    t.string  "line_number"
    t.text    "params"
    t.text    "data"
    t.string  "timestamp"
    t.string  "event_hash"
    t.string  "level"
    t.string  "tenant"
    t.integer "user_id"
  end

  create_table "home_launchers", :force => true do |t|
    t.text     "description"
    t.string   "button"
    t.string   "url"
    t.boolean  "enable",             :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "anchor"
  end

  create_table "instant_win_prizes", :force => true do |t|
    t.string   "title",                  :null => false
    t.text     "description"
    t.integer  "contest_periodicity_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "instantwins", :force => true do |t|
    t.integer  "contest_periodicity_id", :null => false
    t.datetime "time_to_win_start",      :null => false
    t.string   "title"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.datetime "time_to_win_end"
    t.string   "unique_id"
  end

  create_table "interactions", :force => true do |t|
    t.string  "name"
    t.integer "seconds",               :default => 0
    t.string  "when_show_interaction"
    t.boolean "required_to_complete"
    t.integer "resource_id"
    t.string  "resource_type"
    t.integer "call_to_action_id"
  end

  add_index "interactions", ["name"], :name => "index_interactions_on_name", :unique => true

  create_table "likes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "notices", :force => true do |t|
    t.integer  "user_id"
    t.text     "html_notice"
    t.datetime "last_sent"
    t.boolean  "viewed",      :default => false
    t.boolean  "read",        :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.text     "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.text     "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "periodicity_types", :force => true do |t|
    t.string   "name",       :null => false
    t.integer  "period"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "periods", :force => true do |t|
    t.string   "kind"
    t.datetime "start_datetime"
    t.datetime "end_datetime"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "plays", :force => true do |t|
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "text_before"
    t.string   "text_after"
  end

  create_table "playticket_events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contest_periodicity_id"
    t.integer  "points_spent"
    t.datetime "used_at"
    t.boolean  "winner",                 :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "instantwin_id"
  end

  create_table "promocodes", :force => true do |t|
    t.string   "title"
    t.string   "code"
    t.integer  "property_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "quizzes", :force => true do |t|
    t.string   "question",                               :null => false
    t.integer  "cache_correct_answer", :default => 0
    t.integer  "cache_wrong_answer",   :default => 0
    t.string   "quiz_type"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "one_shot",             :default => true
  end

  create_table "rankings", :force => true do |t|
    t.integer  "reward_id",     :null => false
    t.string   "name"
    t.string   "title"
    t.string   "period"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "rank_type"
    t.string   "people_filter"
  end

  create_table "registrations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "releasing_files", :force => true do |t|
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "reward_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "reward_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "rewards", :force => true do |t|
    t.string   "title"
    t.text     "short_description"
    t.text     "long_description"
    t.string   "button_label"
    t.integer  "cost"
    t.datetime "valid_from"
    t.datetime "valid_to"
    t.string   "video_url"
    t.string   "media_type"
    t.integer  "currency_id"
    t.boolean  "spendable"
    t.boolean  "countable"
    t.boolean  "numeric_display"
    t.string   "name"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "preview_image_file_name"
    t.string   "preview_image_content_type"
    t.integer  "preview_image_file_size"
    t.datetime "preview_image_updated_at"
    t.string   "main_image_file_name"
    t.string   "main_image_content_type"
    t.integer  "main_image_file_size"
    t.datetime "main_image_updated_at"
    t.string   "media_file_file_name"
    t.string   "media_file_content_type"
    t.integer  "media_file_file_size"
    t.datetime "media_file_updated_at"
    t.string   "not_awarded_image_file_name"
    t.string   "not_awarded_image_content_type"
    t.integer  "not_awarded_image_file_size"
    t.datetime "not_awarded_image_updated_at"
    t.string   "not_winnable_image_file_name"
    t.string   "not_winnable_image_content_type"
    t.integer  "not_winnable_image_file_size"
    t.datetime "not_winnable_image_updated_at"
  end

  add_index "rewards", ["name"], :name => "index_rewards_on_name", :unique => true

  create_table "settings", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "shares", :force => true do |t|
    t.text     "description"
    t.string   "message"
    t.string   "share_type"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "link"
  end

  create_table "synced_log_files", :force => true do |t|
    t.string   "pid"
    t.string   "server_hostname"
    t.datetime "timestamp"
  end

  add_index "synced_log_files", ["pid", "server_hostname", "timestamp"], :name => "index_synced_log_files_on_pid_and_server_hostname_and_timestamp", :unique => true

  create_table "tag_fields", :force => true do |t|
    t.integer  "tag_id"
    t.string   "name"
    t.string   "field_type"
    t.text     "value"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "description"
    t.boolean  "locked"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "tags_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "other_tag_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "tags_tags", ["other_tag_id"], :name => "index_tags_tags_on_other_tag_id"
  add_index "tags_tags", ["tag_id"], :name => "index_tags_tags_on_tag_id"

  create_table "uploads", :force => true do |t|
    t.integer  "call_to_action_id",      :null => false
    t.boolean  "releasing"
    t.text     "releasing_description"
    t.boolean  "privacy"
    t.text     "privacy_description"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "upload_number"
    t.string   "watermark_file_name"
    t.string   "watermark_content_type"
    t.integer  "watermark_file_size"
    t.datetime "watermark_updated_at"
  end

  create_table "user_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "approved"
  end

# Could not dump table "user_counters" because of following StandardError
#   Unknown type 'json' for column 'counters'

  create_table "user_interactions", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "interaction_id",                :null => false
    t.integer  "answer_id"
    t.integer  "counter",        :default => 1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "like"
    t.text     "outcome"
  end

  create_table "user_rewards", :force => true do |t|
    t.integer  "user_id"
    t.integer  "reward_id"
    t.boolean  "available"
    t.integer  "counter",    :default => 0
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "period_id"
  end

  create_table "user_upload_interactions", :force => true do |t|
    t.integer  "user_id",           :null => false
    t.integer  "call_to_action_id", :null => false
    t.integer  "upload_id",         :null => false
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",       :null => false
    t.string   "encrypted_password",     :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar_selected",        :default => "upload"
    t.string   "swid"
    t.boolean  "privacy"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "role"
    t.string   "authentication_token"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "cap"
    t.string   "location"
    t.string   "province"
    t.string   "address"
    t.string   "phone"
    t.string   "number"
    t.boolean  "rule"
    t.date     "birth_date"
    t.string   "username"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
