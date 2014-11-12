
class Sites::Ballando::CallToActionController < CallToActionController

  def setup_update_interaction_response_info(response) 
    response["contest_points_counter"] = [SUPERFAN_CONTEST_POINTS_TO_WIN - (get_counter_about_user_reward(SUPERFAN_CONTEST_REWARD, false) || 0), 0].max
    response
  end

=begin  
  def upload
    @upload_interaction = Interaction.find(params[:interaction_id])
    @cloned_cta = create_user_calltoactions(@upload_interaction.resource)

    if @cloned_cta.errors.any?
      render template: "/upload_interaction/new"
    else
      flash[:notice] = "Caricamento completato con successo"
      redirect_to "/upload_interaction/new"
    end
  end
=end
  
  def upload
    @upload_interaction = Interaction.find(params[:interaction_id])
    @cloned_cta = create_user_calltoactions(@upload_interaction.resource)
    @calltoaction = @upload_interaction.call_to_action

    if @cloned_cta.errors.any?
      @gallery_tag = get_tag_with_tag_about_call_to_action(@calltoaction, "gallery").first
      @extra_info = cache_short(get_gallery_extra_info_key()) do
        extra = Hash.new
        TagField.where("tag_id = ?", @gallery_tag.id).each do |tf|
          if tf.field_type == "STRINGA"
            extra[tf.name] = tf.value
          else
            extra[tf.name] = tf.upload
          end
        end
        extra
      end
      render template: "/gallery/show"
    else
      flash[:notice] = "Caricamento completato con successo"
      redirect_to "/gallery/#{@calltoaction.id}"
    end

  end


  def create_user_calltoactions(upload_interaction)  
    
      cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
      cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
      cloned_cta.save
      cloned_cta

  end
  
end