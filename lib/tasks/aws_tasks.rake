require 'aws-sdk'
require 'logger'

#!/bin/env ruby
# encoding: utf-8

# deploy_setting
# transcoding:
#   :access_key_id: access_key_id
#   :secret_access_key: secret_access_key
#   :region: region
#   :pipeline_id: pipeline_id
#   :bucket: bucket

namespace :aws_tasks do

  def current_timestamp()
    "[#{Time.now.utc.strftime("%Y-%m-%d %H:%M:%S.%6N")}]"
  end

  def deploy_settings_example()
    { 
      "transcoding" => {
        :access_key_id => "access_key_id",
        :secret_access_key => "secret_access_key",
        :region => "region",
        :pipeline_id => "pipeline_id",
        :bucket => "bucket"
      }
    }.to_yaml
  end

  task :finalize_transcoding, [:tenant, :app_root_path, :s3_output_folder] => :environment do |t, args|

    logger = Logger.new("#{args.app_root_path}/log/finalize_transcoding.log")
    logger.info "#{current_timestamp} finalize transcoding start"

    switch_tenant(args.tenant)

    transcoding_settings = get_deploy_setting("sites/disney/transcoding", false)
    if transcoding_settings

      s3 = AWS::S3.new(
        access_key_id: transcoding_settings[:access_key_id],
        secret_access_key: transcoding_settings[:secret_access_key],
        s3_endpoint: "s3-#{transcoding_settings[:region]}.amazonaws.com"
      )

      bucket = s3.buckets[transcoding_settings[:bucket]]

      ctas = CallToAction.where("aux->>'aws_transcoding_media_status' = 'inprogress'")

      ctas.each do |cta|
        object = bucket.objects["#{args.s3_output_folder}/web_mp4/aws_transcoding-#{cta.id}"]
        
        aux = JSON.parse(cta.aux || "{}")

        if object.exists?
          
          begin

            time_start = Time.now.utc
            logger.info "#{current_timestamp} move media transcoded in cta #{cta.id} start"

            media_image_key = remove_head_slash(cta.media_image.path)
            media_file_name = "media-#{cta.id}"
            media_destination = remove_head_slash("#{cta.media_image.path.sub(cta.media_image_file_name, "")}#{media_file_name}")

            # Save original media in another folder and replace this media with transcoded media
            bucket.objects[media_image_key].copy_to("#{args.s3_output_folder}/original/#{cta.id}-#{cta.media_image_file_name}", acl: :public_read)
            object.copy_to(media_destination, acl: :public_read)

            aux["aws_transcoding_media_status"] = "done"

            cta.update_attributes(
              aux: aux.to_json, 
              media_image_content_type: object.content_type, 
              media_image_file_size: object.content_length,
              media_image_file_name: media_file_name
            )

            if cta.errors.empty?
              delete_duplicate_medias(bucket, [object.key, media_image_key])
              time_end = Time.now.utc
              logger.info "#{current_timestamp} move media transcoded in cta #{cta.id} end [content_length #{object.content_length}]"
            else
              logger.error("errors in cta #{cta.id} saving")
            end

          rescue Exception => exception
            logger.error("#{current_timestamp} exception in media replace block: #{exception} - #{exception.backtrace[0, 5]}")
          end

        else

          if transcoding_error?(aux["aws_transcoding_media_start_time"].to_time) 
            logger.error("#{current_timestamp} errors in cta #{cta.id} transcoding")
            aux["aws_transcoding_media_status"] = "error"
            cta.update_attribute(:aux, aux.to_json)
          end

        end
      end
    else
      logger.error("#{current_timestamp} missing deploy setting configuration: #{deploy_settings_example}")
    end

    logger.info "#{current_timestamp} finalize transcoding end"

  end

  def transcoding_error?(transcoding_start_time)
    (Time.now.utc - transcoding_start_time)/1.hour >= 1
  end

  def delete_duplicate_medias(bucket, medias)
    medias.each do |media|
      bucket.objects.delete(media)
    end
  end

  def remove_head_slash(media_image_path)
    media_image_path[0] = '' if media_image_path[0] == "/"
    media_image_path
  end
 
  task :initialize_transcoding, [:tenant, :app_root_path, :s3_output_folder] => :environment do |t, args|

    # https://console.aws.amazon.com/elastictranscoder/home?region=eu-west-1#
    switch_tenant(args.tenant)

    logger = Logger.new("#{args.app_root_path}/log/initialize_transcoding.log")
    logger.info "#{current_timestamp} initialize transcoding start"

    transcoding_settings = get_deploy_setting("sites/disney/transcoding", false)
    if transcoding_settings

      # Create the client for Elastic Transcoder.
      transcoder_client = AWS::ElasticTranscoder::Client.new(
        region: transcoding_settings[:region],
        access_key_id: transcoding_settings[:access_key_id],
        secret_access_key: transcoding_settings[:secret_access_key]
      )

      # This is the ID of the Elastic Transcoder pipeline that was created when
      # setting up your AWS environment:
      # http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/sample-code.html#ruby-pipeline
      # https://console.aws.amazon.com/elastictranscoder/home?region=eu-west-1#
      pipeline_id = transcoding_settings[:pipeline_id]

      ctas = CallToAction.where("aux->>'aws_transcoding_media_status' = 'requested'")
      ctas.each do |cta|

        logger.info "#{current_timestamp} start transcoding job for cta #{cta.id}"
        video_url = remove_head_slash(cta.media_image.path)
        output_key = "aws_transcoding-#{cta.id}"

        job = video_transcoding(output_key, video_url, transcoder_client, pipeline_id, args.s3_output_folder)

        aux = JSON.parse(cta.aux)
        aux["aws_transcoding_media_status"] = "inprogress"
        aux["aws_transcoding_media_start_time"] = Time.now.utc
        cta.update_attribute(:aux, aux.to_json)

      end
    else
      logger.error("#{current_timestamp} missing deploy setting configuration: #{deploy_settings_example}")
    end

    logger.info "#{current_timestamp} initialize transcoding end"

  end

  def video_transcoding(output_key, video_url, transcoder_client, pipeline_id, s3_output_folder)
    web_mp4_preset_id = '1351620000001-100070' # web_mp4

    job = transcoder_client.create_job(
      pipeline_id: pipeline_id,
      input: { 
        key: video_url
      },
      output: {
        key: 'web_mp4/' + output_key,
        preset_id: web_mp4_preset_id
      },
      output_key_prefix: "#{s3_output_folder}/"
    )[:job]

    #puts 'Job has been created: ' + JSON.pretty_generate(job)

    job
  end

end

