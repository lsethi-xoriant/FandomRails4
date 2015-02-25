require 'fandom_utils'
require 'sites/maxibon/utils'
include FandomUtils

Fandom::Application.routes.draw do

  use_doorkeeper

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  constraints(SiteMatcher.new('coin')) do
    match "/play", :to => "instantwin#play_ticket", defaults: { format: 'json' }
    scope module: "sites" do
      scope module: "coin" do
        root :to => "application#index"
        match '/privacy_policy', :to => 'application#show_privacy_policy'
        match '/cookies_policy', :to => 'application#show_cookies_policy'
        match '/stores', :to => 'application#show_stores'
        match "profile/complete_for_contest", :to => "application#complete_for_contest", defaults: { format: 'json' }
        devise_scope :user do
          post "/users", :to => "registrations#create"
          match 'auth/:provider/callback', :to => 'sessions#create'
        end
      end
    end
  end

  constraints(SiteMatcher.new('orzoro')) do
    scope module: "sites" do
      scope module: "orzoro" do
        root :to => "application#index"
        match "/cup_redeemer/step_1", to: "cup_redeemer#step_1"
        match "/cup_redeemer/step_1/update", to: "cup_redeemer#step_1_update"
        match "/cup_redeemer/step_2", to: "cup_redeemer#step_2"
        match "/next_calltoaction", to: "call_to_action#next_calltoaction_in_category", defaults: { format: 'json' }
        match "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
        resources :call_to_action, only: :show
      end
    end
  end

  constraints(SiteMatcher.new('disney')) do
    scope module: "sites" do
      scope module: "disney" do

        namespace :easyadmin do
          match "/dashboard", :to => "easyadmin#dashboard"
        end
        
        match "/iur", to: "application#iur"
        match "/browse", :to => "browse#index"
        match "/browse/full_search", :to => "browse#full_search"
        match "/browse/full_search_load_more", :to => "browse#full_search_load_more"
        match "/browse/search", :to => "browse#search"
        match "/browse/redirect/:query", :to => "browse#index"
        match "/browse/view_all/:id", :to => "browse#index_category"
        match "/browse/view_recent", :to => "browse#view_all_recent"
        match "/browse/view_recent/load_more", :to => "browse#view_all_recent_load_more"
        match "/browse/index_category_load_more", :to => "browse#index_category_load_more"
        match "/browse/category/:id", :to => "browse#index_category"
        match "profile", :to => "profile#index"
        match "profile/index", :to => "profile#index_mobile"
        match "profile/rankings", :to => "profile#rankings"
        match "profile/rewards", :to => "profile#rewards"
        match "profile/notices", :to => "profile#notices"
        match "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"
        match "profile/complete_registration", :to => "profile#complete_registration", defaults: { format: 'json' }
        
        devise_scope :user do
          post "/users", :to => "registrations#create"
          put "/users/edit", :to => "registrations#update"
          match "/iur/sign_in", to: "registrations#iur"
          get "/users/sign_in", to: "application#iur"
          match "/users/sign_in_admin", to: "sessions#new"
          get "/users/sign_up", to: "sessions#new"
          match "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
        end

        resources :call_to_action, only: :show
        
        match "ordering_ctas", to: "call_to_action#ordering_ctas" , defaults: { format: 'json' }
        match "rss", :to => "rss#calltoactions", defaults: { format: 'rss' }
        match "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }
        match "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
        root :to => "application#index"

      end
    end  
  end
  
  
  constraints(SiteMatcher.new('ballando')) do
    match "/profile", :to => "profile#badges"

    devise_scope :user do
      scope module: "sites" do
        scope module: "ballando" do

          resources :call_to_action

          root :to => "application#index"

          match "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }

          match "/captcha", :to => "application#generate_captcha", defaults: { format: 'json' }

          match "/redirect_top_with_cookie", :to => "application#redirect_top_with_cookie"

          match '/users/sign_in', :to => 'sessions#ballando_new', :as => 'user_sign_in'

          match "/users/gigya_socialize_redirect", :to => "application#gigya_socialize_redirect"

          match "/custom_call_to_action/:id/next", :to => "custom_call_to_action#show_next_calltoaction"
          match "/custom_call_to_action/:id", :to => "custom_call_to_action#show"

          match "/refresh_top_window", :to => "application#refresh_top_window"
  
          match "/users/rai/sign_out", :to => "sessions#ballando_destroy"
          match "/users/rai/sign_up/create", :to => "registrations#ballando_create"
          match "/users/rai/sign_in/create", :to => "sessions#ballando_create"
          match "/users/rai/sign_in_from_provider/create", :to => "sessions#ballando_create_from_provider", defaults: { format: 'json' }
  
          match "/profile/widget", :to => "iframe_profile#show"
          match "/carousel/widget", :to => "iframe_carousel#main"
          match "/carousel_footer/widget", :to => "iframe_carousel#footer"
          
          match "/iframe/check", :to => "iframe_check#show"
          match "/iframe/get_check", :to => "iframe_check#get_check_template"
          match "/iframe/do_check", :to => "iframe_check#do_check"

          match "/upload_interaction/new", :to => "upload_interaction#new"
          match "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"

          match "/generate_cover_for_calltoaction", :to => "application#generate_cover_for_calltoaction", defaults: { format: 'json' }
          match "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }
          
          match "/special_guest", :to => "application#redirect_into_special_guest"
          
          match "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

          match "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
          match "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
          match "/new_comments_polling", :to => "call_to_action#new_comments_polling", defaults: { format: 'json' }
        end
      end
    end
  end

   constraints(SiteMatcher.new('forte')) do
    match "/profile", :to => "profile#badges"

    devise_scope :user do
      scope module: "sites" do
        scope module: "forte" do

          resources :call_to_action

          match "/captcha", :to => "application#generate_captcha", defaults: { format: 'json' }

          match "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }

          match "/update_reward_calltoactions_in_page", to: "call_to_action#update_reward_calltoactions_in_page", defaults: { format: 'json' }

          match "/", :to => "application#index"

          match "/redirect_top_with_cookie", :to => "application#redirect_top_with_cookie"

          match '/users/sign_in', :to => 'sessions#forte_new', :as => 'user_sign_in'

          match "/users/gigya_socialize_redirect", :to => "application#gigya_socialize_redirect"

          match "/custom_call_to_action/:id/next", :to => "custom_call_to_action#show_next_calltoaction"
          match "/custom_call_to_action/:id", :to => "custom_call_to_action#show"

          match "/refresh_top_window", :to => "application#refresh_top_window"
  
          match "/users/rai/sign_out", :to => "sessions#forte_destroy"
          match "/users/rai/sign_up/create", :to => "registrations#forte_create"
          match "/users/rai/sign_in/create", :to => "sessions#forte_create"
          match "/users/rai/sign_in_from_provider/create", :to => "sessions#forte_create_from_provider", defaults: { format: 'json' }
  
          match "/profile/widget", :to => "iframe_profile#show"
          match "/carousel/widget", :to => "iframe_carousel#main"
          match "/carousel_footer/widget", :to => "iframe_carousel#footer"
          
          match "/iframe/check", :to => "iframe_check#show"
          match "/iframe/get_check", :to => "iframe_check#get_check_template"
          match "/iframe/do_check", :to => "iframe_check#do_check"

          match "/upload_interaction/new", :to => "upload_interaction#new"
          match "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"

          match "/generate_cover_for_calltoaction", :to => "application#generate_cover_for_calltoaction", defaults: { format: 'json' }
          match "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }
          
          match "/special_guest", :to => "application#redirect_into_special_guest"
          
          match "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

          match "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
          match "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
          match "/new_comments_polling", :to => "call_to_action#new_comments_polling", defaults: { format: 'json' }
        end
      end
    end
  end

  match "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }

  match "/user_cookies", to: "application#user_cookies", defaults: { format: 'json' }

  match "/random_calltoaction", to: "call_to_action#random_calltoaction", defaults: { format: 'json' }

  match "/file_upload_too_large", to: "application#file_upload_too_large"

  match "/redirect_into_iframe_calltoaction/:calltoaction_id", to: "application#redirect_into_iframe_calltoaction"
  match "/facebook_share_page_with_meta/:calltoaction_id", to: "call_to_action#facebook_share_page_with_meta"
  match "/profile/update_avatar", to: "application#update_avatar_image"

  match "/redirect_into_iframe_path", :to => "application#redirect_into_iframe_path"
  match "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"
  match "/upload", :to => "call_to_action#upload"
  
  match "/browse", :to => "browse#index"
  match "/browse/:tagname", :to => "browse#index"
  match "/browse/search", :to => "browse#search"
  match "/browse/full_search", :to => "browse#full_search"
  match "/browse/fullscreen", :to => "browse#index_fullscreen"
  match "/browse/view_all/:id", :to => "browse#index_category"
  match "/browse/view_recent", :to => "browse#view_all_recent"
  match "/browse/view_recent/load_more", :to => "browse#view_all_recent_load_more"
  match "/browse/index_category_load_more", :to => "browse#index_category_load_more"
  match "/browse/category/:id", :to => "browse#index_category"
  
  match "/gallery", :to => "gallery#index"
  match "/gallery/:id", :to => "gallery#show"
  match "/gallery/how_to/:id", :to => "gallery#how_to"
  
  #match "/classifica/:id", :to => "ranking#show"
  match "classifiche", :to => "ranking#show_rankings_page"
  match "bootcamp", :to => "ranking#show_vote_rankings_page"
  match "/ranking/page", :to => "ranking#get_rank_page"
  match "/ranking/vote/page", :to => "ranking#get_vote_rank_page"
  match "/ranking/show/:id", :to => "ranking#show_single_rank"
  match "/ranking/vote/:id", :to => "ranking#show_vote_rank"
  
  match "/healthcheck", :to => "health_check#health_check"
  
  match "/profile/superfan_contest", :to => "profile#superfan_contest"

  namespace :easyadmin do

    match "/", :to => "easyadmin#index"

    match "tag/filter", :to => "tag#filter"
    match "tag/clone/:id", :to => "tag#clone"
    match "tag/ordering", :to => "tag#ordering"
    match "tag/retag", :to => "tag#retag_tag"

    resources :home_launchers

    resources :tag

    resources :ranking

    resources :vote_ranking

    # USER
    match "user", :to => "easyadmin#index_user"
    match "export_users", :to => "easyadmin#export_users"
    match "user/show/:id", :to => "easyadmin#show_user"
    match "user/filter", :to => "easyadmin#filter_user"

    # WINNER
    match "winner", :to => "easyadmin#index_winner"
    match "winner/send_email_to_winner", :to => "easyadmin#send_email_to_winner"

    # CALL TO ACTION
    match "cta", :to => "call_to_action#index_cta"
    match "cta/filter", :to => "call_to_action#filter"
    match "cta/template", :to => "call_to_action#index_cta_template"
    match "cta_user", :to => "call_to_action#index_user_generated_cta"
    match "cta/to_approve", :to => "call_to_action#index_user_cta_to_be_approved"
    match "cta/approved", :to => "call_to_action#index_user_cta_approved"
    match "cta/not_approved", :to => "call_to_action#index_user_cta_not_approved"
    match "cta/:id/update_cta_status", :to => "call_to_action#update_cta_status"
    match "cta/filter/:title_filter/:tag_filter", :to => "call_to_action#filter_calltoaction"
    match "cta/new/", :to => "call_to_action#new_cta"
    match "cta/show/:id", :to => "call_to_action#show_cta", :as => :cta_show
    match "cta/show_details/:id", :to => "call_to_action#show_details"
    match "cta/edit/:id/", :to => "call_to_action#edit_cta"
    match "cta/save", :to => "call_to_action#save_cta"
    match "cta/update", :to => "call_to_action#update_cta"
    match "cta/hide/:id", :to => "call_to_action#hide_cta"
    match "cta/clone/:id", :to => "call_to_action#clone"
    match "cta/update_user_cta_image/:id", :to => "call_to_action#edit_cta"

    # TAG CTA
    match "cta/tag/:id", :to => "easyadmin#tag_cta"
    match "cta/tag/:id/update", :to => "easyadmin#tag_cta_update"

    # PROMOCODE
    match "promocode", :to => "easyadmin#index_promocode"
    match "promocode/new_promocode", :to => "easyadmin#new_promocode"
    match "promocode/create_promocode", :to => "easyadmin#create_promocode"
    
    # PRIZE
    match "reward", :to => "easyadmin_reward#index"
    match "reward/filter", :to => "easyadmin_reward#filter"
    match "reward/show/:id", :to => "easyadmin_reward#show"
    match "reward/edit/:id", :to => "easyadmin_reward#edit"
    match "reward/new", :to => "easyadmin_reward#new"
    match "reward/save", :to => "easyadmin_reward#save"
    match "reward/update", :to => "easyadmin_reward#update"
    match "reward/clone/:id", :to => "easyadmin_reward#clone"
    
    # INSTANT WIN
    match "contest", :to => "easyadmin#index_contest"
    match "contest/new", :to => "easyadmin#new_contest"
    match "contest/edit", :to => "easyadmin#edit_contest"
    match "contest/save", :to => "easyadmin#save_contest"
    match "periodicity/new", :to => "easyadmin#new_periodicity"
    match "periodicity/save", :to => "easyadmin#save_periodicity"
    match "periodicity", :to => "easyadmin#index_periodicity"
    match "instantwin/generate/:id", :to => "instantwin#create_wins"
    match "instantwin_prize", :to => "easyadmin#index_prize"
    match "instantwin_prize/new", :to => "easyadmin#new_prize"
    match "instantwin_prize/edit/:id", :to => "easyadmin#edit_prize"
    match "instantwin_prize/save", :to => "easyadmin#save_prize"
    match "instantwin_prize/update", :to => "easyadmin#update_prize"
    
    # COMMENT
    match "comments/approved", :to => "comments#index_comment_approved"
    match "comments/to_approved", :to => "comments#index_comment_to_be_approved"
    match "comments/not_approved", :to => "comments#index_comment_not_approved"
    match "comments/:comment_id/update_comment_status", :to => "comments#update_comment_status"

    match "dashboard", :to => "easyadmin#dashboard"
    match "published", :to => "easyadmin#published"
    match "dashboard/get_current_month_event", :to => "easyadmin#get_current_month_event", defaults: { format: 'json' }
    match "dashboard/update_activated_at", :to => "easyadmin#update_activated_at", defaults: { format: 'json' }
    match "most_clicked_interactions", :to => "easyadmin#index_most_clicked_interactions"
    match "reward_cta_unlocked", :to => "easyadmin#index_reward_cta_unlocked"
    
    match "events", :to => "easyadmin_event_console#index"
    match "events/filter", :to => "easyadmin_event_console#apply_filter", defaults: { format: 'json' }
    
    match "notices", :to => "easyadmin_notice#index"
    match "notices/new", :to => "easyadmin_notice#new"
    match "notices/create", :to => "easyadmin_notice#create"
    match "notices/filter", :to => "easyadmin_notice#apply_filter", defaults: { format: 'json' }
    match "notices/sendnotice", :to => "easyadmin_notice#resend_notice", defaults: { format: 'json' }
    
    match "rules", :to => "easyadmin_rewarding_rules#index"
    match "rules/save", :to => "easyadmin_rewarding_rules#save"
    
    # SETTING
    match "settings/browse", :to => "settings#browse_settings"
    match "settings/browse/save", :to => "settings#save_browse_settings"
    match "settings/ranking", :to => "settings#ranking_settings"
    match "settings/ranking/save", :to => "settings#save_ranking_settings"
    match "settings/notifications", :to => "settings#notifications_settings"
    match "settings/notifications/save", :to => "settings#save_notifications_settings"
    match "settings/profanities", :to => "settings#profanities_settings"
    match "settings/profanities/save", :to => "settings#save_profanities_settings"
  end

  match '/facebook_app', to: "application#facebook_app"

  match '/next_interaction', to: "call_to_action#next_interaction", defaults: { format: 'json' }
  match '/check_next_interaction', to: "call_to_action#check_next_interaction", defaults: { format: 'json' }
  
  #reward
  match "/reward/catalogue", :to => "reward#index"
  match "/reward/catalogue/all", :to => "reward#show_all_catalogue"
  match "/reward/catalogue/available/all", :to => "reward#show_all_available_catalogue"
  match "/reward/catalogue/my/all", :to => "reward#show_all_my_catalogue"
  match "/reward/show/:reward_id", :to => "reward#show"
  match "/reward/buy", :to => "reward#buy_reward", defaults: { format: 'json' }
  match "/reward/how_to", :to => "reward#how_to"

  # Captcha.
  match "/captcha", :to => "captcha#generate_captcha", defaults: { format: 'json' }

  # Instagram subscribe. 
  match "/instagram_verify_token_callback", :to => "application#instagram_verify_token_callback"

  match "/how_to", :to => "application#how_to"
  match "/landing", :to => "landing#index"

  match "profile", :to => "profile#index"
  match "profile/levels", :to => "profile#levels"
  match "profile/badges", :to => "profile#badges"
  match "profile/prizes", :to => "profile#prizes"
  match "profile/rankings", :to => "profile#rankings"
  match "profile/rewards", :to => "profile#rewards"
  match "profile/notices", :to => "profile#notices"
  match "profile/notices/mark_as_read", :to => "notice#mark_as_read", defaults: { format: 'json' }
  match "profile/notices/mark_all_as_read", :to => "notice#mark_all_as_read", defaults: { format: 'json' }
  match "profile/notices/mark_as_viewed", :to => "notice#mark_as_viewed", defaults: { format: 'json' }
  match "profile/notices/mark_all_as_viewed", :to => "notice#mark_all_as_viewed", defaults: { format: 'json' }
  match "profile/notices/get_recent_notice", :to => "notice#get_user_latest_notices", defaults: { format: 'json' }
  match "profile/remove-provider/:provider", :to => "profile#remove_provider"
  match "profile/complete_for_contest", :to => "profile#complete_for_contest", defaults: { format: 'json' }

  match "/sign_in_fb_from_page", :to => "application#sign_in_fb_from_page"
  match "/sign_in_tt_from_page", :to => "application#sign_in_tt_from_page"
  match "/sign_in_simple_from_page", :to => "application#sign_in_simple_from_page"

  match "/playticket", :to => "instantwin#play_ticket_mb"
  match "/winners", :to => "instantwin#show_winners"

  match "/anchor_provider_from_calltoaction/:calltoaction_id", to: "application#anchor_provider_from_calltoaction"

  devise_for :users, :controllers => { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords" }

  devise_scope :user do
    match "/password_feedback", :to => "passwords#feedback"
    match "/users/sign_in", :to => "sessions#create", :as => "user_sign_in"
    match "/users/sign_out", :to => "sessions#destroy"
    match "auth/:provider/callback", :to => "sessions#create"
    match "/auth/failure" => "sessions#omniauth_failure"
    match "/profile/edit", :to => "registrations#edit"
  end

  match "/user_event/update_answer", :to => "call_to_action#update_answer", defaults: { format: 'json' }
  match "/user_event/update_download", :to => "call_to_action#update_download", defaults: { format: 'json' }
  match "/user_event/update_like", :to => "call_to_action#update_like", defaults: { format: 'json' }
  match "/user_event/update_check", :to => "call_to_action#update_check", defaults: { format: 'json' }
  match "/user_event/share/:provider", :to => "call_to_action#share", defaults: { format: 'json' }
  match "/user_event/share_free/:provider", :to => "call_to_action#share_free", defaults: { format: 'json' }

  match "/gallery", :to => "gallery#index"

  match "/update_call_to_action_in_page_with_tag", :to => "application#update_call_to_action_in_page_with_tag", defaults: { format: 'json' }

  match "/update_calltoaction_content", :to => "call_to_action#update_calltoaction_content", defaults: { format: 'json' }
  match "/calltoaction_overvideo_end", :to => "call_to_action#calltoaction_overvideo_end", defaults: { format: 'json' }
  match "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

  match "/delete_current_user_interactions", :to => "application#delete_current_user_interactions"

  match "rss", :to => "rss#rss", defaults: { format: 'rss' }

  match "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
  match "/last_linked_calltoaction", to: "call_to_action#last_linked_calltoaction", defaults: { format: 'json' }

  match "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
  match "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
  match "/comments_polling", :to => "call_to_action#comments_polling", defaults: { format: 'json' }

  match "rss", :to => "rss#property_rss", defaults: { format: 'rss' }
  match "check_level_and_badge_up", :to => "call_to_action#check_level_and_badge_up", defaults: { format: 'json' }
  match "get_overvideo_during_interaction", :to => "call_to_action#get_overvideo_during_interaction", defaults: { format: 'json' }
  
  match "/call_to_action/:id/:descendent_id", to: "call_to_action#show"

  resources :call_to_action, only: :show do
    match "/next_disqus_page", :to => "call_to_action#next_disqus_page", defaults: { format: 'json' }
  end

  match "/newsletter_unsubscribe/:email/:security_token", :to => "newsletter#unsubscribe", :constraints => { :email => /.*/ }
  match "email_notifications_unsubscribe/:username/:security_token", :to => "notice#unsubscribe", :constraints => { :username => /.*/ }

  match "/tag/:name", :to => "application#index"
  root :to => "application#index"

  # error handling
  match "/404", :to => "http_error#not_found_404"
  match "/500", :to => "http_error#internal_error_500"
  match "/422", :to => "http_error#unprocessable_entity_422"

end
