require 'test_helper'

class CallToActionTest < ActionController::TestCase
  include Devise::TestHelpers
  include ApplicationHelper

  setup :initialize_tenant

  # TEST GALLERY SECTION

  test "top ctas taken and appended ordered by comments are correctly shown" do
    limit = 3
    ordering = "comment"

    property_tag = get_default_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: ordering }, limit)
 
    assert ctas_ordered_by_comment_count?(cta_info_list)

    calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
    cta_info_list, has_more = get_next_ctas(property_tag, calltoaction_ids_shown, ordering, limit)

    assert ctas_ordered_by_comment_count?(cta_info_list)
  end

  test "top ctas taken and appended are tagged with param property" do
    limit = 3
    ordering = "recent"

    property_tag = get_random_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: ordering }, limit)

    assert ctas_tagged_with?(cta_info_list, property_tag)

    calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
    cta_info_list, has_more = get_next_ctas(property_tag, calltoaction_ids_shown, ordering, limit)

    result = true
    cta_info_list.each do |cta_info|
      result = result && !calltoaction_ids_shown.include?(cta_info["calltoaction"]["id"])
    end
    assert result

    assert ctas_tagged_with?(cta_info_list, property_tag)
  end

  test "there is append other ctas if ctas count is bigger than limit" do
    limit = 3
    property_tag = get_random_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: "recent" }, limit)
    ctas_count = get_ctas(property_tag).count

    assert (has_more && cta_info_list.count < ctas_count) || (!has_more && cta_info_list.count >= ctas_count)
  end

  def get_ids_from_cta_info_list(cta_info_list)
    calltoaction_ids_shown = []
    cta_info_list.each do |cta_info|
      calltoaction_ids_shown << cta_info["calltoaction"]["id"] 
    end
    calltoaction_ids_shown
  end

  def ctas_tagged_with?(cta_info_list, tag)
    result = true
    cta_info_list.each do |cta_info|
      cta = CallToAction.find(cta_info["calltoaction"]["id"])
      cta_tagged = cta.call_to_action_tags.find_by_tag_id(tag.id).present?
      result = result && cta_tagged
    end
    result
  end

  def ctas_ordered_by_comment_count?(cta_info_list)
    prev_counter = nil
    result = true

    cta_info_list.each do |cta_info|
      counter = get_comment_counter(cta_info)
      result = result && (prev_counter.nil? || prev_counter >= counter)
      prev_counter = counter
    end

    result
  end

  def get_next_ctas(property_tag, calltoaction_ids_shown, ordering, limit)
    params =  { ordering: ordering, calltoaction_ids_shown: calltoaction_ids_shown }
    get_ctas_for_stream(property_tag.name, params, limit)
  end

  def get_comment_counter(cta_info)
    counter = 0
    cta_info["calltoaction"]["interaction_info_list"].each do |interaction_info|
      if interaction_info["interaction"]["resource_type"] == "comment"
        counter = interaction_info["interaction"]["resource"]["counter"]
        break
      end
    end
    counter
  end

  def get_random_property
    random_property_name = $site.allowed_context_roots.sample
    Tag.find(random_property_name)
  end

  def get_default_property
    Tag.find($site.default_property)
  end

  def current_user
    User.offset(rand(User.count)).first
  end

  def initialize_tenant
    switch_tenant("fandom")
  end
end
