require 'fandom_utils'

module CommentHelper
  
  ############ BALLANDO ############
  def get_last_comments_to_view(interaction)
    cache_short(get_calltoaction_last_comments_cache_key(interaction.call_to_action_id)) do
      comments_to_shown = interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5).to_a
      comments_count = interaction.resource.user_comment_interactions.approved.count
      [comments_to_shown, comments_count]
    end
  end
  ############ BALLANDO ############

  def get_comments_approved(interaction)
    cache_short(get_comments_approved_cache_key(interaction.id)) do
      comments = interaction.resource.user_comment_interactions.approved.order("updated_at DESC").limit(5).to_a
      comments_total_count = interaction.resource.user_comment_interactions.approved.count

      comment_for_comment_info = Array.new
      comments.each do |comment|
        comment_for_comment_info << build_comment_for_comment_info(comment)
      end

      [comment_for_comment_info, comments_total_count]
    end
  end

  def build_comment_for_comment_info(comment, evidence = false) 
    {
      "id" => comment.id,
      "text" => comment.text,
      "updated_at" => comment.updated_at.strftime("%Y/%m/%d %H:%M:%S"),
      "evidence" => evidence,
      "user" => {
        "name" => "#{comment.user.first_name} #{comment.user.last_name}",
        "avatar" => user_avatar(comment.user)
      }
    }
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
