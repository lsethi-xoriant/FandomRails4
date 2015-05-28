class AddIndexInInstagramMediaIdForCallToAction < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_call_to_actions_on_instagram_media_id ON call_to_actions ((aux->>'instagram_media_id'))")
  end

  def down
    execute("DROP INDEX index_call_to_actions_on_instagram_media_id")
  end
end