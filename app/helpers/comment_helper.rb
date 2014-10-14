require 'fandom_utils'

module CommentHelper
  
  def get_last_comments_to_view(interaction)
    interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5)
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
