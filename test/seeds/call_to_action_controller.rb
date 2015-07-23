call_to_action = CallToAction.where(:title => "Call to action with comments for testing", :name => "call-to-action-with-comments-for-testing").first_or_create
comment = Comment.where(:title => "comment-resource-for-testing").first_or_create
interaction = Interaction.where(:call_to_action_id => call_to_action.id, :resource_type => "Comment", :resource_id => comment.id).first_or_create

interaction