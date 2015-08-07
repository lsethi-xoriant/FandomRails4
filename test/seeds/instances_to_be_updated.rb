cta = CallToAction.where(:title => "Cta to update", :name => "cta-to-update").first_or_create
cta.update_attribute(:activated_at, DateTime.now)
tag = Tag.where(:name => "sample-tag" , :description => "Sample tag").first_or_create
CallToActionTag.where(:call_to_action_id => cta.id, :tag_id => tag.id).first_or_create
tag_2 = Tag.where(:name => "sample-tag-2" , :description => "Sample tag").first_or_create
TagsTag.where(:tag_id => tag.id, :other_tag_id => tag_2.id).first_or_create

user_cta = CallToAction.where(:title => "User cta to update", :name => "user-cta-to-update").first_or_create
user_cta.update_attribute(:user_id, 1)

[cta, user_cta]