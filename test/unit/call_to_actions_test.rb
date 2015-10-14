require 'test_helper'

class CallToActionTest < ActionController::TestCase
  include ApplicationHelper

  LIMIT = 3

  setup :initialize_tenant

  test "exclude cta from stream" do
    property_tag = get_default_property()

    cta_in_next_page_offset = LIMIT + 1
    cta_in_next_page = get_ctas(property_tag).offset(cta_in_next_page_offset).first

    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { "exclude_cta_with_ids" => [cta_in_next_page.id] }, LIMIT)
  
    assert ctas_not_include_cta_with_id?(cta_info_list, cta_in_next_page.id), "cta to exclude is present"
  
    if has_more
      calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
      params = { "exclude_cta_with_ids" => [cta_in_next_page.id], calltoaction_ids_shown: calltoaction_ids_shown }
      cta_info_list, has_more = get_ctas_for_stream(property_tag.name, params, LIMIT)
      
      assert ctas_not_include_cta_with_id?(cta_info_list, cta_in_next_page.id), "cta to exclude is present in next page"
    end
  end

  test "all ctas in the head and append later ordered by comments are shown in the correct order" do
    ordering = "comment"

    property_tag = get_default_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: ordering }, LIMIT)
 
    assert ctas_ordered_by_comment_count?(cta_info_list), "not all ctas are correctly ordered"

    if has_more
      calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
      params =  { ordering: ordering, calltoaction_ids_shown: calltoaction_ids_shown }
      cta_info_list, has_more = get_ctas_for_stream(property_tag.name, params, LIMIT)

      assert ctas_ordered_by_comment_count?(cta_info_list), "not all appended ctas are correctly ordered"
    end
  end

  test "all ctas in the head and append later belong to the current property" do
    ordering = "recent"

    property_tag = get_default_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: ordering }, LIMIT)

    assert ctas_tagged_with?(cta_info_list, property_tag), "not all ctas are tagged with current property tag"

    if has_more
      calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
      params =  { ordering: ordering, calltoaction_ids_shown: calltoaction_ids_shown }
      cta_info_list, has_more = get_ctas_for_stream(property_tag.name, params, LIMIT)

      result = true
      cta_info_list.each do |cta_info|
        result = result && !calltoaction_ids_shown.include?(cta_info["calltoaction"]["id"])
      end
      assert result, "appended ctas include almost one cta already shown"

      assert ctas_tagged_with?(cta_info_list, property_tag), "not all appended ctas are tagged with current property tag"
    end
  end

  test "there are other ctas to be added if the variable has more is true" do
    property_tag = get_default_property()
    cta_info_list, has_more = get_ctas_for_stream(property_tag.name, { ordering: "recent" }, LIMIT)
    ctas_count = get_ctas(property_tag).count

    assert (has_more && cta_info_list.count < ctas_count) || (!has_more && cta_info_list.count >= ctas_count), "has more variable is not correctly set"
  end

  test "all galleries ctas in the head and append later are assigned to an user" do
    params = adjust_params_with_gallery_info({}, "all")
    cta_info_list, has_more = get_ctas_for_stream(nil, params, LIMIT)
 
    assert approved_ctas?(cta_info_list), "not all ctas are approved"
    assert user_ctas?(cta_info_list), "not all ctas are assigned to an user"

    if has_more
      calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
      params = adjust_params_with_gallery_info({ calltoaction_ids_shown: calltoaction_ids_shown }, "all")
      cta_info_list, has_more = get_ctas_for_stream(nil, params, LIMIT)

      assert approved_ctas?(cta_info_list), "not all appended ctas are approved"
      assert user_ctas?(cta_info_list), "not all appended ctas are assigned to an user"
    end
  end

  test "all gallery ctas in the head and append later are assigned to an user" do
    gallery_tag = get_random_gallery_tag()

    gallery_cta = CallToAction.includes(:call_to_action_tags).where("call_to_actions.user_id IS NULL AND call_to_action_tags.tag_id = ?", gallery_tag.id).references(:call_to_action_tags).first

    if gallery_cta.present?
      params = adjust_params_with_gallery_info({}, gallery_cta.id)
      cta_info_list, has_more = get_ctas_for_stream(nil, params, LIMIT)
   
      assert approved_ctas?(cta_info_list), "not all ctas are approved"
      assert user_ctas?(cta_info_list), "not all ctas are assigned to an user"

      if has_more
        calltoaction_ids_shown = get_ids_from_cta_info_list(cta_info_list)
        params = adjust_params_with_gallery_info({ calltoaction_ids_shown: calltoaction_ids_shown }, gallery_cta.id)
        cta_info_list, has_more = get_ctas_for_stream(nil, params, LIMIT)

        assert approved_ctas?(cta_info_list), "not all appended ctas are approved"
        assert user_ctas?(cta_info_list), "not all appended ctas are assigned to an user"
      end
    end
  end

  private

  def approved_ctas?(cta_info_list)
    approved_ctas = true
    cta_info_list.each do |cta_info|
      cta = CallToAction.find(cta_info["calltoaction"]["id"])
      approved_ctas = approved_ctas && cta.approved
    end
    approved_ctas
  end

  def user_ctas?(cta_info_list)
    cta_info_list.each do |cta_info|
      if cta_info["calltoaction"]["user"].nil?
        return false
      end
    end
    return true
  end

  def get_ids_from_cta_info_list(cta_info_list)
    calltoaction_ids_shown = []
    cta_info_list.each do |cta_info|
      calltoaction_ids_shown << cta_info["calltoaction"]["id"] 
    end
    calltoaction_ids_shown
  end

  def ctas_tagged_with?(cta_info_list, tag)
    cta_info_list.each do |cta_info|
      cta_tagged = CallToActionTag.where(tag_id: tag.id, call_to_action_id: cta_info["calltoaction"]["id"]).any?
      unless cta_tagged
        return false
      end
    end
    return true
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

  def adjust_params_with_gallery_info(params, gallery_cta_id)
    params["other_params"] = {}
    params["other_params"]["gallery"] = {}
    params["other_params"]["gallery"]["calltoaction_id"] = gallery_cta_id
    params
  end

  def get_random_gallery_tag
    get_tags_with_tag("gallery").sample
  end

  def ctas_not_include_cta_with_id?(cta_info_list, cta_to_exclude_id)
    result = true
    cta_info_list.each do |cta_info|
      result = result && cta_info["calltoaction"]["id"] != cta_to_exclude_id 
    end
    result
  end

end
