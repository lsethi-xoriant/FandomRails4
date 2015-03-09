require 'aws-sdk'

#!/bin/env ruby
# encoding: utf-8

namespace :aws_tasks do

  task :restore_media_from_transcoding, [:tenant] => :environment do |t, args|

    transcoding_settings = get_deploy_setting("sites/disney/transcoding", false)

    puts "s3-#{transcoding_settings[:region]}.amazonaws.com"
      s3 = AWS::S3.new(
        access_key_id: transcoding_settings[:access_key_id],
        secret_access_key: transcoding_settings[:secret_access_key],
        s3_endpoint: "s3-#{transcoding_settings[:region]}.amazonaws.com"
      )

      bucket = s3.buckets[transcoding_settings[:bucket]]

      bucket.objects.with_prefix('elastic-transcoder-dev/web_mp4').each do |object|
        puts object.key
      end

      #tree = bucket.as_tree
      #directories = tree.children.select(&:branch?).collect(&:prefix)
      #puts directories      


      #image_to_backup = open(gallery.picture.url)
      #object_img = bucket.objects[ "gallery_backup/#{ gallery.id }_#{ gallery.picture_file_name }" ]
      #object_img.write(image_to_backup, :acl => :public_read)


  end
 
  task :transcoding, [:tenant] => :environment do |t, args|

    switch_tenant(args.tenant)

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

      ctas = CallToAction.where("aux->>'aws_transcoding' <> ''")
      ctas.each do |cta|
        puts "Transcoding #{cta.name}"
        video_url = JSON.parse(cta.aux)["aws_transcoding"]
        output_key = "aws_transcoding-#{cta.id}"
        video_transcoding(output_key, video_url, transcoder_client, pipeline_id)
      end

    end


  end

  def video_transcoding(output_key, video_url, transcoder_client, pipeline_id)
    web_mp4_preset_id = '1351620000001-100070' # web_mp4
    video_url[0] = '' if video_url[0] == "/"

    job = transcoder_client.create_job(
      pipeline_id: pipeline_id,
      input: { 
        key: video_url
      },
      output: {
        key: 'web_mp4/' + output_key,
        preset_id: web_mp4_preset_id
      },
      output_key_prefix: "elastic-transcoder-dev/"
    )[:job]

    puts 'Job has been created: ' + JSON.pretty_generate(job)
  end


end

