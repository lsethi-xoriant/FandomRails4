require 'fandom_utils'

module CommentHelper
  
  def get_last_comments_to_view(interaction)
    cache_short(get_calltoaction_last_comments_cache_key(interaction.call_to_action_id)) do
      comments_to_shown = interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5).to_a
      comments_count = interaction.resource.user_comment_interactions.approved.count
      [comments_to_shown, comments_count]
    end
  end

  def get_last_comments_to_view_date(interaction)
    init_comments_show = interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5)
    init_comments_show.any? ? init_comments_show.last.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N") : nil
  end

  def get_first_comments_to_view_date(interaction)
    init_comments_show = interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5)
    init_comments_show.any? ? init_comments_show.first.updated_at.strftime("%Y-%m-%d %H:%M:%S.%6N") : nil
  end

  def get_comments_append_counter(interaction)
    [interaction.resource.user_comment_interactions.approved.count - get_last_comments_to_view(interaction).count, 0].max
  end
  
end
