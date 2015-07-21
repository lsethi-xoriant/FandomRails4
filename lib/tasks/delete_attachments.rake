namespace :attachments do

  desc "Migrates the tag_fields table to the tag.extra_field JSON."
  task :delete => :environment do
    tenants = all_site_ids_with_db
    tenants.each do |tenant|
      delete_attachments(tenant)
    end
  end

  def delete_attachments(tenant)
    puts "-------------- deleting attachments from #{tenant} ------------------"
    Apartment::Tenant.switch(tenant)
    
    # this is quite dirty, but required for paperclip when called from rake scripts
    $site = TEST_SITE
    $site.id = tenant
    
    Attachment.all.each do |attachment|
      puts "deleting #{attachment.data.url}"
      attachment.data.destroy
      attachment.destroy
    end
  end
  
end