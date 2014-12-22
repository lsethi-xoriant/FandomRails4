namespace :cache do

  desc "Migrates the tag_fields table to the tag.extra_field JSON."
  task :update_hourly => :environment do
    update_all_tenants do |tenant|
      update_hourly(tenant)
    end
  end
  
  def update_all_tenants(&block)
    tenants = all_site_ids_with_db
    tenants.each do |tenant|
      yield(tenant)
    end
  end

  def update_hourly(tenant)
    if get_deploy_setting("sites/#{tenant}/update_cache", false)
      puts "------------------------------------------------------------------------------------------------"
      switch_tenant(tenant)
      
      # TODO: actual implementation for the specific tenant
    end
  end
  
end