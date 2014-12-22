namespace :rewards do
  desc "For every user apply the context-dependent rewarding system rules."
  task :compute_outcomes => :environment do
#    apply_all_sites do |site_id|
    ['fandom'].each do |site_id|
      compute_outcomes(site_id)
    end
  end
  
  def compute_outcomes(site_id)
    puts "------------------------------------------------------------------------------------------------"
    switch_tenant(site_id)
    User.all.each_with_index do |user, index|
      start_time = Time.now.utc
      compute_and_save_context_rewards(user)
      total_time = Time.now.utc - start_time
      puts "user #{index} done: #{total_time}"
    end
  end
  
end