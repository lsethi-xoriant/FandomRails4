require 'rake'
require 'csv'
#require 'ruby-debug'

desc "Migrate old orzoro users to new users table"

task :migrate_orzoro_users, [:users_csv_file, :user_redeem_cups_csv_file] => :environment do |task, args|
  migrate_orzoro_users(args.users_csv_file, args.user_redeem_cups_csv_file)
end

def migrate_orzoro_users(users_csv_file, user_redeem_cups_csv_file)

  switch_tenant('orzoro')

  users_array = CSV.read(users_csv_file, :col_sep => "|")
  user_redeem_cups_array = CSV.read(user_redeem_cups_csv_file, :col_sep => "|")

  users_hash_array = build_hash_array(users_array)
  user_redeem_cups_hash_array = build_hash_array(user_redeem_cups_array)

  users_array_count = users_array.count
  puts "#{users_array_count} lines to iterate...\n\n"

  migration_errors = 0
  email_present = 0
  no_cups_redeemed = 0

  start_time = Time.now

  users_hash_array.each_with_index do |user, index|
    if User.find_by_email(user["email"])
      email_present += 1
    else
      last_cup_redeem = find_line_by_email(user["email"], user_redeem_cups_hash_array)
      no_cups_redeemed += 1 if last_cup_redeem.empty?

      terms = user["terms"] == "t" ? true : false
      newsletter = user["newsletter"] == "t" ? true : false
      aux = { "terms" => terms, 
              "sync_timestamp" => Time.now,
              "cup_redeem" => [{ "identity" => { "terms" => terms, "newsletter" => newsletter } }]
            }.to_json

      user_params = Hash.new

      user_params[:id] = user["id"]
      user_params[:email] = user["email"]
      # user_params[:encrypted_password] = user["encrypted_password"]
      user_params[:reset_password_token] = user["reset_password_token"]
      user_params[:reset_password_sent_at] = user["reset_password_sent_at"]
      user_params[:remember_created_at] = user["remember_created_at"]
      user_params[:sign_in_count] = user["sign_in_count"]
      user_params[:current_sign_in_at] = user["current_sign_in_at"]
      user_params[:last_sign_in_at] = user["last_sign_in_at"]
      user_params[:current_sign_in_ip] = user["current_sign_in_ip"]
      user_params[:last_sign_in_ip] = user["last_sign_in_ip"]
      user_params[:first_name] = user["first_name"]
      user_params[:last_name] = user["last_name"]
      # user_params[:swid] = nil
      user_params[:privacy] = user["privacy"] == "t" ? true : false
      user_params[:confirmed_at] = user["created_at"]
      user_params[:confirmation_sent_at] = user["created_at"]
      user_params[:role] = user["role"]
      user_params[:created_at] = user["created_at"]
      user_params[:updated_at] = user["updated_at"]
      user_params[:cap] = last_cup_redeem["cap_ship"]
      user_params[:location] = last_cup_redeem["city_ship"]
      user_params[:province] = last_cup_redeem["province_ship"]
      user_params[:address] = last_cup_redeem["address_ship"]
      user_params[:phone] = last_cup_redeem["cellulare_ship"]
      user_params[:number] = last_cup_redeem["n_civico_ship"]
      user_params[:birth_date] = build_birth_date(last_cup_redeem)
      user_params[:username] = user["nickname"]
      user_params[:newsletter] = newsletter
      user_params[:aux] = aux
      user_params[:gender] = last_cup_redeem["gender"]
      user_params[:password] = (0..12).map { (97 + rand(26)).chr }.join # random generated

      # encrypted_password, swid, confirmation_token, unconfirmed_email, authentication_token, rule, avatar_selected_url will
      # not be set

      u = User.create(user_params)

      unless u.errors.full_messages.blank?
        puts "Error on user #{user["nickname"]} (#{user["email"]}):\n#{u.errors.full_messages}\n\n"
        migration_errors += 1
      end
    end

    if (index + 1) % 100 == 0
      puts "#{index + 1} lines iterated in #{ Time.now - start_time } s\n"
      start_time = Time.now
    end
  end

  puts "#{users_array_count} lines iterated \n"
  puts "#{users_array_count - migration_errors - email_present}/#{users_array_count} users successfully migrated\n"
  puts "#{migration_errors} errors\n#{email_present} email already present\n"
  puts "#{no_cups_redeemed} users never redeemed cups\n"

end

def build_hash_array(array)
  res = []
  labels = []

  array.each_with_index do |line, line_i|
    if line_i == 0
      line.each do |label|
        labels << label
      end
    else
      hash = {}
      line.each_with_index do |value, value_i|
        hash.merge!({ labels[value_i] => value })
      end
      res << hash
    end
  end
  res
end

def find_line_by_email(email, user_redeem_cups_hash_array)
  res = {}

  user_redeem_cups_hash_array.each do |line|
    if line["email"] == email
      created_at = res["created_at"].nil? ? "1800-01-01" : res["created_at"]
      if Time.parse(created_at) < Time.parse(line["created_at"])
        res = line
      end
    end
  end
  res
end

def build_birth_date(user_redeem_cups_hash)
  res = nil
  unless user_redeem_cups_hash["day_birth_on"].nil?
    birth_date = "#{user_redeem_cups_hash["year_birth_on"]}-#{sprintf("%02d", user_redeem_cups_hash["month_birth_on"])}-#{sprintf("%02d", user_redeem_cups_hash["day_birth_on"])}"
    res = Time.parse(birth_date)
  end
end
