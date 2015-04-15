module GrafitagHelper

  def build_grafitag_for_tag(tag, tag_name)
    grafitag = get_tag_with_tag_about_tag(tag, tag_name).first
    if grafitag.present?
      build_grafitag(grafitag)
    else
      nil
    end
  end

  def build_grafitag_for_calltoaction(calltoaction, tag_name)
    grafitag = get_tag_with_tag_about_call_to_action(calltoaction, tag_name).first
    if grafitag.present?
      build_grafitag(grafitag)
    else
      nil
    end
  end

  def build_grafitag(grafitag)
    {
      "label_background" => get_extra_fields!(grafitag)["label-background"],
      "icon" => get_extra_fields!(grafitag)["icon"],
      "image" => (get_extra_fields!(grafitag)["image"]["url"] rescue nil),
      "label_color" => get_extra_fields!(grafitag)["label-color"] || "#fff",
      "title" => grafitag.title,
      "name" => grafitag.name
    }
  end

end