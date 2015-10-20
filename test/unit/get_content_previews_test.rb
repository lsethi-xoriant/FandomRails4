require "test_helper"

class GetContentPreviewsTest < ActiveSupport::TestCase

  def setup
    switch_tenant("fandom")
    @tags = load_seed("get_content_previews") # [main_tag, other_tag_1, other_tag_2]
    @users = load_seed("default_seed")
    @main_tag = @tags[0]
  end

  test "simple get content previews" do

    content_previews = get_content_previews(@main_tag.name)
    assert content_previews.contents.count == 4, "There are #{content_previews.contents.count} contents instead of 4"

  end

  test "get content previews with other tags" do

    other_tags = [@tags[1]]
    content_previews = get_content_previews(@main_tag.name, other_tags)
    assert content_previews.contents.count == 2,  "There are #{content_previews.contents.count} contents instead of 2"
    Rails.cache.clear

    other_tags = [@tags[2]]
    content_previews = get_content_previews(@main_tag.name, other_tags)
    assert content_previews.contents.count == 2,  "There are #{content_previews.contents.count} contents instead of 2"
    Rails.cache.clear

    other_tags = [@tags[1]] + [@tags[2]]
    content_previews = get_content_previews(@main_tag.name, other_tags)
    assert content_previews.contents.count == 0,  "There are #{content_previews.contents.count} contents instead of 0"
    Rails.cache.clear

  end

  test "get content previews with number of elements" do

    for i in 1..4
      check_number_of_contents(@main_tag, i)
    end

    Rails.cache.clear

  end

  test "get content previews with ordering" do

    @main_tag.update_attribute(:extra_fields, { "ordering" => "tag-1-test,tag-2-test" })
    content_previews = get_content_previews(@main_tag.name)
    assert content_previews.contents[0].title == "Tag 1 test", "First content should be \"Tag 1 test\", but it is \"#{content_previews.contents[0].title}\""
    assert content_previews.contents[1].title == "Tag 2 test", "Second content should be \"Tag 2 test\", but it is \"#{content_previews.contents[1].title}\""
    Rails.cache.clear

    @main_tag.update_attribute(:extra_fields, { "ordering" => "cta-1-test,cta-2-test" })
    content_previews = get_content_previews(@main_tag.name)
    assert content_previews.contents[0].title == "Cta 1 test", "First content should be \"Cta 1 test\", but it is \"#{content_previews.contents[0].title}\""
    assert content_previews.contents[1].title == "Cta 2 test", "Second content should be \"Cta 2 test\", but it is \"#{content_previews.contents[1].title}\""
    Rails.cache.clear

  end

  test "get content previews with ordering and related" do

    Rails.cache.clear
    @main_tag.update_attribute(:extra_fields, { "ordering" => "tag-1-test,tag-2-test" })
    content_previews = get_content_previews(@main_tag.name, [], { :related => true })
    assert content_previews.contents[0].title != "Tag 1 test", "First content should not be \"Tag 1 test\""
    assert content_previews.contents[1].title != "Tag 2 test", "Second content should not be \"Tag 2 test\""

  end

  def current_user
    @users.sample
  end

  def check_content(content, params)
    errors = []
    params.each do |key, value|
      errors << "content.#{key} should be #{value}, but it is #{content.send(key)}" if content.send(key) != value
    end
    errors
  end

  def check_number_of_contents(main_tag, n)
    Rails.cache.clear
    content_previews = get_content_previews(main_tag.name, [], {}, n)
    assert content_previews.contents.count == n,  "There are #{content_previews.contents.count} contents instead of #{n}"
  end

end