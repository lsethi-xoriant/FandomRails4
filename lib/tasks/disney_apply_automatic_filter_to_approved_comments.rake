# encoding: utf-8

require 'rake'
require 'ruby-debug'

desc "Apply automatic profanity filter to disney approved comments"

task :apply_profanity_filter => :environment do
  apply_profanity_filter
end

def apply_profanity_filter
  switch_tenant('disney')
  start_time = Time.now

  count = 0
  matches = "ID user comment interaction\tTesto user comment interaction\tMatch\n"
  pattern_array = Array.new
  profanity_words = Setting.find_by_key("profanity.words").value

  profanity_words.split(",").each do |exp|
    pattern_array.push(build_regexp(exp))
  end
  profanities_regexp = Regexp.new("(" + pattern_array.join(')|(') + ")")

  call_to_action_ids = CallToAction.where("user_id IS NOT NULL").pluck(:id)
  comment_ids = Interaction.where("call_to_action_id IN (?) AND resource_type = 'Comment'", call_to_action_ids).pluck(:resource_id)
  comment_interactions = UserCommentInteraction.where("approved = true AND comment_id IN (#{ comment_ids.empty? ? "-1" : comment_ids.join(",") })")

  puts "#{comment_interactions.count} user comment interactions to analyze. \nRunning..."

  comment_interactions.each_with_index do |comment_interaction, index|
    match = profanities_regexp.match(comment_interaction.text.downcase)
    if match
      count += 1
      matches += "#{comment_interaction.id}\t#{comment_interaction.text}\t#{match[0]}\n"
    end
    if (index + 1) % 2000 == 0
      puts "#{index + 1} user comment interactions analyzed (#{count} comments with profanities found so far)"
      STDOUT.flush
    end
  end

  puts "All approved comments checked. Elapsed time: #{Time.now - start_time}s"
  puts "#{count} comments with profanities found."
  puts "Matches: \n#{matches}"
end

def build_regexp(line)
  string = "(^|[ \\-,_xy]+)"
  line.strip.each_char do |c|
    if REGEX_SPECIAL_CHARS.include? c
      c = "\\" + c
    end
    if c != " "
      string << "[ \\-.,_]*" + c
    end
  end
  string << "($|[ \\-,_xy]+)"
end
