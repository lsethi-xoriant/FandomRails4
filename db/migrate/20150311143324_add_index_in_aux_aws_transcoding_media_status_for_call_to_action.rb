class AddIndexInAuxAwsTranscodingMediaStatusForCallToAction < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_call_to_actions_on_aux_aws_transcoding_media_status ON call_to_actions ((aux->>'aws_transcoding_media_status'))")
  end

  def down
    execute("DROP INDEX index_call_to_actions_on_aux_aws_transcoding_media_status")
  end
end