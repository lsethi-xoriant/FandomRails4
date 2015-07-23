cta_1 = CallToAction.where({ 
  name: "cta-1-test", 
  title: "Cta 1 test", 
  description: "Call to action test 1", 
  media_type: "VOID", 
  activated_at: DateTime.parse("2015-03-16 10:00"), 
  slug: "cta-1-test", 
  media_data: nil 
}).first_or_create

cta_2 = CallToAction.where({ 
  name: "cta-2-test", 
  title: "Cta 2 test", 
  description: "Call to action test 2", 
  media_type: "VOID", 
  activated_at: DateTime.parse("2015-03-16 12:00"), 
  slug: "cta-2-test", 
  media_data: nil 
}).first_or_create

main_tag = Tag.where({
  name: "main-tag-test", 
  description: "Main tag for testing", 
  locked: false, 
  title: "Main Tag test", 
  slug: "main-tag-test"
}).first_or_create

tag_1 = Tag.where({
  name: "tag-1-test", 
  description: "Tag 1 for testing", 
  locked: false, 
  title: "Tag 1 test", 
  slug: "tag-1-test"
}).first_or_create

tag_2 = Tag.where({
  name: "tag-2-test", 
  description: "Tag 2 for testing", 
  locked: false, 
  title: "Tag 2 test", 
  slug: "tag-2-test"
}).first_or_create

other_tag_1 = Tag.where({
  name: "other-tag-1-test", 
  description: "Other Tag 1 for testing", 
  locked: false, 
  title: "Other Tag 1 test", 
  slug: "other-tag-1-test"
}).first_or_create

other_tag_2 = Tag.where({
  name: "other-tag-2-test", 
  description: "Other Tag 2 for testing", 
  locked: false, 
  title: "Other Tag 2 test", 
  slug: "other-tag-2-test"
}).first_or_create

CallToActionTag.where(:call_to_action_id => cta_1.id, :tag_id => main_tag.id).first_or_create
CallToActionTag.where(:call_to_action_id => cta_2.id, :tag_id => main_tag.id).first_or_create
CallToActionTag.where(:call_to_action_id => cta_1.id, :tag_id => other_tag_1.id).first_or_create
CallToActionTag.where(:call_to_action_id => cta_2.id, :tag_id => other_tag_2.id).first_or_create

TagsTag.where(:tag_id => tag_1, :other_tag_id => main_tag.id).first_or_create
TagsTag.where(:tag_id => tag_2, :other_tag_id => main_tag.id).first_or_create
TagsTag.where(:tag_id => tag_1, :other_tag_id => other_tag_1.id).first_or_create
TagsTag.where(:tag_id => tag_2, :other_tag_id => other_tag_2.id).first_or_create

[main_tag, other_tag_1, other_tag_2]
