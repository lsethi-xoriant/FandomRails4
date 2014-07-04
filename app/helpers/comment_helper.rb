require 'fandom_utils'

module CommentHelper
  
  def get_last_comments_to_view(interaction)
    interaction.resource.user_comments.publish.order("published_at DESC").limit(5)
  end

  def get_last_comments_to_view_date(interaction)
    init_comments_show = interaction.resource.user_comments.publish.order("published_at DESC").limit(5)
    init_comments_show.any? ? init_comments_show.last.published_at : nil
  end

  def get_first_comments_to_view_date(interaction)
    init_comments_show = interaction.resource.user_comments.publish.order("published_at DESC").limit(5)
    init_comments_show.any? ? init_comments_show.first.published_at : nil
  end

  def get_comments_append_counter(interaction)
    [interaction.resource.user_comments.publish.count - get_last_comments_to_view(interaction).count, 0].max
  end
  
end
