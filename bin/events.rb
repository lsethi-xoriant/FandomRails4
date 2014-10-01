#!/usr/bin/ruby

# monitor event logs in the production environment. It requires the command line tool 'xtail'

require 'json'

RAILS_LOG_DIR = "~/railsapps/Fandom/shared/log/events"

def main
  if ARGV.size >= 1
    dir = ARGV[0]
  else
    dir = RAILS_LOG_DIR
  end

  IO.popen("xtail #{dir}").each do |line|
    if line.start_with?("{")
      json = JSON.parse(line)
      data_to_string = json['data'].map { |key, value| "#{key}: #{value}" }
      data_to_string = data_to_string.join(", ")

      puts "#{json['timestamp']} #{json['file_name']}:#{json['line_number']} #{json['level'].upcase} #{json['message']} -- #{data_to_string}"
    end
  end
end

main()