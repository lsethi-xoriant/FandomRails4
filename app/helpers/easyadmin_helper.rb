module EasyadminHelper

  def link_to_add_check_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Check.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/check-form", f: builder)
    end
    link_to_function(name, "add_check_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_comment_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Comment.new(title: "#COMMENT#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/comment-form", f: builder)
    end
    link_to_function(name, "add_comment_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_download_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Download.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/download-form", f: builder)
    end
    link_to_function(name, "add_download_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_play_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Play.new(title: "#PLAY#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/play-form", f: builder)
    end
    link_to_function(name, "add_play_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_share_fb_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Share.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/share-fb-form", f: builder)
    end
    link_to_function(name, "add_share_fb_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_share_tt_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Share.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/share-tt-form", f: builder)
    end
    link_to_function(name, "add_share_tt_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_share_email_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Share.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/share-email-form", f: builder)
    end
    link_to_function(name, "add_share_email_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_like_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Like.new(title: "#LIKE#{ DateTime.now.strftime("%Y%m%d") }")
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/like-form", f: builder)
    end
    link_to_function(name, "add_like_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_quiz_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Quiz.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/quiz-form", f: builder)
    end
    link_to_function(name, "add_quiz_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_versus_fields(name, f, association)
    new_object = Interaction.new
    new_object.resource = Quiz.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/versus-form", f: builder)
    end
    link_to_function(name, "add_versus_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary")
  end

  def link_to_add_answer_quiz_fields(name, f, association)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/answer-quiz-form", f: builder)
    end
    link_to_function(name, "add_answer_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_answer_versus_fields(name, f, association)
    new_object = Answer.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/answer-versus-form", f: builder)
    end
    link_to_function(name, "add_answer_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_add_contest_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/easyadmin/contest-form", f: builder)
    end
    link_to_function(name, "add_contest_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end
  
  def link_to_add_tag_fields(name, f, association)
    new_object = TagField.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render("/easyadmin/tag/tag-field-form", f: builder)
    end
    link_to_function(name, "add_tag_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\")", class: "btn btn-primary btn-xs")
  end

  def link_to_remove_check_fields(name)
    link_to_function(name, "remove_check_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_download_fields(name)
    link_to_function(name, "remove_download_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_quiz_fields(name)
    link_to_function(name, "remove_quiz_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_versus_fields(name)
    link_to_function(name, "remove_versus_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_answer_quiz_fields(name)
    link_to_function(name, "remove_answer_quiz_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_answer_versus_fields(name)
    link_to_function(name, "remove_answer_versus_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_like_fields(name)
    link_to_function(name, "remove_like_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_play_fields(name)
    link_to_function(name, "remove_play_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_comment_fields(name)
    link_to_function(name, "remove_comment_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_fb_fields(name)
    link_to_function(name, "remove_share_fb_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_tt_fields(name)
    link_to_function(name, "remove_share_tt_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_share_email_fields(name)
    link_to_function(name, "remove_share_email_fields(this)", class: "btn btn-warning btn-xs")
  end

  def link_to_remove_contest_fields(name)
    link_to_function(name, "remove_contest_fields(this)", class: "btn btn-warning btn-xs")
  end
  
  def link_to_remove_tag_fields(name)
    link_to_function(name, "remove_tag_fields(this)", class: "btn btn-warning btn-xs")
  end

end

