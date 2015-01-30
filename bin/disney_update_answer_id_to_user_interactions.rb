require "pg"
require "csv"
require "json"
require "yaml"

def main

  if ARGV.size != 3
    puts <<-EOF
      Usage: #{$0} <csv_file> <id_map_file> <config.yml>
    EOF
    exit
  end

  csv_file = ARGV[0]
  id_map_file = ARGV[1]
  config = YAML.load_file(ARGV[2].to_s)

  conn = PG::Connection.open(config['db'])

  file = File.open(id_map_file, "rb")
  maps = file.read # string

  users_string = maps.slice((maps.index('users:'))..-1)
  users_string = users_string.slice(users_string.index('{'), users_string.index('}'))[1 .. -8]
  s = users_string.split(',').map { |pair| pair.strip.split('=>').map { |x| "\"#{x.to_i}\"" }.join(':') }.join(',')
  users_hash = JSON.parse("{" + s + "}")

  #users_hash = eval(users_string.slice(users_string.index('{')..users_string.index('}')))
  answers_string = maps.slice((maps.index('answers:'))..-1)
  answers_hash = eval(answers_string.slice(answers_string.index('{')..answers_string.index('}')))
  interactions_string = maps.slice((maps.index('interactions:'))..-1)
  interactions_hash = eval(interactions_string.slice(interactions_string.index('{')..interactions_string.index('}')))

  # user - answer - interaction
  user_answer_interaction_array = CSV.read(csv_file, { :col_sep => ";" })
  count = 0
  start_time = Time.now

  user_answer_interaction_array.each_with_index do |line, i|

    new_user_id = users_hash[line[0]]
    new_answer_id = answers_hash[line[1].to_i]
    new_interaction_id = interactions_hash[line[2].to_i]

    if !new_user_id or !new_answer_id or !new_interaction_id
      puts "------------------#{i}: updating user_id: #{new_user_id}, answer_id: #{new_answer_id}, interaction_id: #{new_interaction_id}..."
      count += 1
    else
      #puts "#{i}: updating user_id: #{new_user_id}, answer_id: #{new_answer_id}, interaction_id: #{new_interaction_id}..."
      if i % 1000 == 0 and i > 0
        puts "#{i} lines iterated in #{Time.now - start_time}"
        STDOUT.flush
      end
      begin
        conn.exec("UPDATE disney.user_interactions SET answer_id = #{new_answer_id} WHERE user_id = #{new_user_id} AND interaction_id = #{new_interaction_id}")
      rescue Exception => exception
        puts "Error on update user_interaction #{new_interaction_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
      end
    end

  end
  puts "#{count} lines with errors"

end

main()