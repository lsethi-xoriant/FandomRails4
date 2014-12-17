namespace :tag_fields do

  desc "Migrates the tag_fields table to the tag.extra_field JSON."
  task :migrate => :environment do
    tenants = ['ballando']
    tenants.each do |tenant|
      migrate(tenant)
    end
  end

  def migrate(tenant)
    puts "-------------- migrating tenant #{tenant} ------------------"
    Apartment::Tenant.switch(tenant)
    
    # this is quite dirty, but required for paperclip when called from rake scripts
    $site = TEST_SITE
    $site.id = tenant
    
    Tag.all.each do |tag|
      puts "migrating #{tag.name}"
      hash = {}
      tag.tag_fields.each do |tag_field|
        if tag_field.field_type == "UPLOAD"
          begin
            attachment = Attachment.create(data: tag_field.upload)
          rescue
            attachment = nil
          end
          if attachment.nil? || attachment.id.nil? # this means that the image is not accessible anymore
            hash[tag_field.name] = "" 
          else
            hash[tag_field.name] = { type: 'media', attachment_id: attachment.id, url: attachment.data.url }
          end
        else
          if tag_field.name.downcase == 'title'
            tag.title = tag_field.value
          end
          hash[tag_field.name] = tag_field.value
        end
      end
      if hash.count > 0
        puts "saving hash: #{hash}"
        tag.extra_fields = hash.to_json
        tag.save
      end
    end
  end
  
end