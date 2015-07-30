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
      comments = interaction.resource.user_comment_interactions.includes(:user).approved.order("updated_at DESC").limit(5).to_a
      comments_total_count = interaction.resource.user_comment_interactions.approved.count

      comment_for_comment_info = Array.new
      comments.each do |comment|
        comment_for_comment_info << build_comment_for_comment_info(comment)
      end

      [comment_for_comment_info, comments_total_count]
    end
  end

  def build_comment_for_comment_info(comment, evidence = false) 
    user = anonymous_user?(comment.user) ? anonymous_user : comment.user 

    {
      "id" => comment.id,
      "text" => comment.text,
      "updated_at" => comment.updated_at.strftime("%Y/%m/%d %H:%M:%S"),
      "evidence" => evidence,
      "user" => {
        "name" => user.username,
        "avatar" => user_avatar(user)
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

  def check_profanity_words_in_comment(text)
    user_comment_text = text.downcase
    profanities_regexp = cache_short(get_profanity_words_cache_key()) do
      pattern_array = Array.new

      profanity_words = Setting.find_by_key("profanity.words")
      if profanity_words
        profanity_words.value.split(",").each do |exp|
          pattern_array.push(build_regexp(exp))
        end
      end
      Regexp.union(pattern_array)
    end
    user_comment_text =~ profanities_regexp
  end

  def build_regexp(line)
    string = "(^|[ \\-,_xy]+)"
    line.strip.each_char do |c|
      if REGEX_SPECIAL_CHARS.include? c
        c = "\\" + c
      end
      if c != " "
        string << "[ \\-.,_]*" + c
      end
    end
    string << "($|[ \\-,_xy]+)"
    Regexp.new(string)
  end
  
  def get_comments_approved_except_ids(user_comments, except_comment_ids)
    if except_comment_ids
      user_comments.approved.where("id NOT IN (?)", except_comment_ids)
    else
      user_comments.approved
    end
  end
  
  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_without_shown = get_comments_approved_except_ids(interaction.resource.user_comment_interactions, params[:comment_ids])
      debugger
      last_comment_shown_date = params[:last_updated_at]
      comments = comments_without_shown.where("date_trunc('seconds', updated_at) <= ?", last_comment_shown_date).order("updated_at DESC").limit(10)
      comments_for_comment_info = Array.new
      comments.each do |comment|
        comments_for_comment_info << build_comment_for_comment_info(comment, true)
      end
      comments_for_comment_info
    end    
  end
  
  def append_or_update_comments(interaction_id, &query_block)
    interaction = Interaction.find(interaction_id)
    response = Hash.new
    
    comments = query_block.call(interaction, response)

    response[:comments] = comments

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end
  
end
