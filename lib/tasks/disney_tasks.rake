#!/bin/env ruby
# encoding: utf-8

namespace :disney_tasks do
 
  task :gallery_contest_backup, [:app_root_path] => :environment do |t, args|

    switch_tenant("disney")

    logger = Logger.new("#{args.app_root_path}/log/gallery_contest_backup.log")

    aws_settings = get_deploy_setting("sites/disney/aws", false)
    s3 = AWS::S3.new(
      access_key_id: aws_settings[:access_key_id],
      secret_access_key: aws_settings[:secret_access_key],
      s3_endpoint: "s3-#{aws_settings[:region]}.amazonaws.com"
    )

    aruba_settings = get_deploy_setting("sites/disney/disney_backup_aws", false)
    aruba_s3 = AWS::S3.new(
      access_key_id: aruba_settings[:access_key_id],
      secret_access_key: aruba_settings[:secret_access_key],
      s3_endpoint: aruba_settings[:s3_endpoint]
    )
    tmp_path = aruba_settings[:download_temp_file]

    aruba_bucket = aruba_s3.buckets[aruba_settings[:bucket]]
    bucket = s3.buckets[aws_settings[:bucket]]

    gallery_tags = Tag.includes(tags_tags: :other_tag).where("other_tags_tags_tags.name = ?", "gallery-with-contest")

    gallery_tags.each do |gallery_tag|
      gallery_ctas = CallToAction.includes(:call_to_action_tags)
        .where("call_to_action_tags.tag_id = ? AND user_id IS NOT NULL", gallery_tag.id)
        .where("activated_at IS NOT NULL")
        .where("(aux->>'aws_transcoding_media_status') IS NULL OR (aux->>'aws_transcoding_media_status') = 'done'")
        .order("call_to_actions.created_at DESC")

      logger.info "#{log_head(gallery_tag.name)} backup start"

      prefix_destination = gallery_tag.name + "/"

      gallery_backup = "\"#;\",\"USER_ID\",\"EMAIL\",\"NOME\",\"COGNOME\",\"SWID\",\"> 17\",\"NOME IMMAGINE BACKUP\",\"INDIRIZZO IMMAGINE S3\"\n"
      
      gallery_ctas.each_with_index do |cta, index|
        logger.info "#{log_head(gallery_tag.name)} cta #{cta.id} tracking start"

        extra_fields = JSON.parse(cta.extra_fields || "{}")
        check_age = extra_fields["age"].present?

        user = cta.user
        backup_media_file_name = generate_backup_media_file_name(cta)
        gallery_backup += "\"##{index}\",\"#{user.id}\",\"#{user.email}\",\"#{user.first_name }\",\"#{user.last_name}\",\"#{user.swid}\",\"#{check_age}\",\"#{backup_media_file_name}\",\"#{cta.media_image.url}\"\n"
        
        begin
          copy_media(prefix_destination, bucket, aruba_bucket, backup_media_file_name, cta.media_image.path, tmp_path)
        rescue Exception => exception
          logger.error("#{log_head(gallery_tag.name)} exception in copy media block: #{exception} - #{exception.backtrace[0, 10]}")
        end
      
      end

      File.open("#{tmp_path}/info.csv", 'wb') do |file|
        file.write(gallery_backup)
      end

      aruba_bucket.objects["#{prefix_destination}info.csv"].write(:file => "#{tmp_path}/info.csv", :sigle_request => true)
      logger.info "#{log_head(gallery_tag.name)} backup end"
    end

  end

  def log_head(gallery_name)
    "[#{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")}][#{gallery_name}]"
  end

  def generate_backup_media_file_name(cta)
    "#{cta.id}_#{cta.media_image_file_name}"
  end

  def remove_head_slash(media_image_path)
    media_image_path[0] = '' if media_image_path[0] == "/"
    media_image_path
  end

  def copy_media(prefix_destination, bucket, aruba_bucket, backup_media_file_name, original_media_path, tmp_path)
    original_media_path = remove_head_slash(original_media_path)
    original_object = bucket.objects["#{original_media_path}"]

    unless aruba_bucket.objects["#{prefix_destination}#{backup_media_file_name}"].exists?
      if original_object.exists?
        File.open("#{tmp_path}/tmp_media", 'wb') do |file|
          original_object.read do |obj_r|
             file.write(obj_r)
          end
        end
      end    
      aruba_bucket.objects["#{prefix_destination}#{backup_media_file_name}"].write(:file => "#{tmp_path}/tmp_media", :sigle_request => true)
    end
  end

end

