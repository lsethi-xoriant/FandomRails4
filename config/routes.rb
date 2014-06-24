require 'fandom_utils'
require 'sites/maxibon/utils'
include FandomUtils

Fandom::Application.routes.draw do

  use_doorkeeper

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # TODO: Maxibon youtube widget url
  match "/youtube", :to => "youtube_widget#index"

  match "/redirect_into_iframe_path", :to => "application#redirect_into_iframe_path"

  namespace :easyadmin do
    match "/", :to => "easyadmin#dashboard"

    match "winner", :to => "easyadmin#index_winner"
    match "winner/send_email_to_winner", :to => "easyadmin#send_email_to_winner"

    match "user/show/:id", :to => "easyadmin#show_user"

    match "cta", :to => "easyadmin#index_cta"
    match "cta/filter/:filter", :to => "easyadmin#filter_cta"
    match "cta/filter/:filter/", :to => "easyadmin#filter_cta"
    match "cta/new/", :to => "easyadmin#new_cta"
    match "cta/show/:id", :to => "easyadmin#show_cta"
    match "cta/edit/:id/", :to => "easyadmin#edit_cta"
    match "cta/save", :to => "easyadmin#save_cta"
    match "cta/update", :to => "easyadmin#update_cta"
    match "cta/hide/:id", :to => "easyadmin#hide_cta"
    match "cta/", :to => "easyadmin#index_cta"

    match "tag", :to => "easyadmin#index_tag"
    match "tag/edit/:id", :to => "easyadmin#edit_tag"
    match "tag/edit/:id/update", :to => "easyadmin#update_tag"
    match "cta/tag/:id", :to => "easyadmin#tag_cta"
    match "cta/tag/:id/update", :to => "easyadmin#tag_cta_update"

    match "promocode", :to => "easyadmin#index_promocode"
    match "promocode/new_promocode", :to => "easyadmin#new_promocode"
    match "promocode/create_promocode", :to => "easyadmin#create_promocode"
    
    # PRIZE
    match "reward", :to => "easyadmin_reward#index"
    match "reward/show/:id", :to => "easyadmin_reward#show"
    match "reward/edit/:id", :to => "easyadmin_reward#edit"
    match "reward/new", :to => "easyadmin_reward#new"
    match "reward/save", :to => "easyadmin_reward#save"
    match "reward/update", :to => "easyadmin_reward#update"
    
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
    match "comment/approved", :to => "easyadmin#index_comment_approved"
    match "comment/toapproved", :to => "easyadmin#index_comment_to_be_approved"
    match "comment/notapproved", :to => "easyadmin#index_comment_not_approved"
    match "comment/notapproved/:property", :to => "easyadmin#index_comment_not_approved"
    match "comment/approved/:property", :to => "easyadmin#index_comment_approved"
    match "comment/toapproved/:property", :to => "easyadmin#index_comment_to_be_approved"
    match "comment/:property/update", :to => "easyadmin#update_comment_pubblished"

    match "dashboard", :to => "easyadmin#dashboard"
    match "published", :to => "easyadmin#published"
    match "dashboard/get_current_month_event", :to => "easyadmin#get_current_month_event", defaults: { format: 'json' }
    match "dashboard/update_activated_at", :to => "easyadmin#update_activated_at", defaults: { format: 'json' }
    
    match "events", :to => "easyadmin_event_console#index"
    match "events/filter", :to => "easyadmin_event_console#apply_filter", defaults: { format: 'json' }
    
    match "notices", :to => "easyadmin_notice#index"
    match "notices/filter", :to => "easyadmin_notice#apply_filter", defaults: { format: 'json' }
  end

  constraints(SiteMatcher.new('maxibon')) do
    constraints(MaxibonUtils::Matcher.new) do
      match '', to: redirect("https://apps.facebook.com/shadostage")
      match '*path', to: redirect("https://apps.facebook.com/shadostage")
    end
  end

  post "/", to: "property#index"
  
  #reward
  match "/reward/catalogue", :to => "reward#index"
  match "/reward/show/:reward_id", :to => "reward#show"
  match "/reward/buy/:reward_id", :to => "reward#buy"
  
  # Captcha.
  match "/captcha", :to => "call_to_action#code_image"

  # Instagram subscribe. 
  match "/instagram_verify_token_callback", :to => "application#instagram_verify_token_callback"

  match "/how_to", :to => "application#how_to"
  match "/landing", :to => "landing#landing_app"
  match "/landing_tab", :to => "landing#landing_tab"

  match "profile", :to => "profile#index"
  match "profile/levels", :to => "profile#levels"
  match "profile/badges", :to => "profile#badges"
  match "profile/rankings", :to => "profile#rankings"
  match "profile/notices", :to => "profile#notices"
  match "profile/notices/mark_as_read", :to => "notice#mark_as_read", defaults: { format: 'json' }
  match "profile/notices/mark_all_as_read", :to => "notice#mark_all_as_read", defaults: { format: 'json' }
  match "profile/notices/mark_as_viewed", :to => "notice#mark_as_viewed", defaults: { format: 'json' }
  match "profile/notices/mark_all_as_viewed", :to => "notice#mark_all_as_viewed", defaults: { format: 'json' }
  match "profile/notices/get_recent_notice", :to => "notice#get_user_latest_notices", defaults: { format: 'json' }
  match "profile/remove-provider/:provider", :to => "profile#remove_provider"
  match "profile/complete_for_contest", :to => "profile#complete_for_contest"

  match "/sign_in_fb_from_page", :to => "application#sign_in_fb_from_page"
  match "/sign_in_tt_from_page", :to => "application#sign_in_tt_from_page"
  match "/sign_in_simple_from_page", :to => "application#sign_in_simple_from_page"
  
  match "/playticket", :to => "instantwin#play_ticket_mb"
  match "/winners", :to => "instantwin#show_winners"

  devise_for :users, :controllers => { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords" }

  devise_scope :user do
    match '/users/sign_in', :to => 'sessions#create', :as => 'user_sign_in'
    match '/users/sign_out', :to => 'sessions#destroy'
    match 'auth/:provider/callback', :to => 'sessions#create'
    match '/auth/failure' => 'sessions#omniauth_failure'
    match '/profile/edit', :to => 'registrations#edit'
  end

  match "/user_event/update_answer", :to => "call_to_action#update_answer", defaults: { format: 'json' }
  match "/user_event/update_download", :to => "call_to_action#update_download", defaults: { format: 'json' }
  match "/user_event/update_like", :to => "call_to_action#update_like", defaults: { format: 'json' }
  match "/user_event/update_check", :to => "call_to_action#update_check", defaults: { format: 'json' }
  match "/user_event/share/:provider", :to => "call_to_action#share", defaults: { format: 'json' }
  match "/user_event/share_free/:provider", :to => "call_to_action#share_free", defaults: { format: 'json' }

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create'
        post 'passwords' => 'passwords#create'
      end
      get "user/me" => "users#me", defaults: { format: 'json' }
      get "calltoaction/index" => "call_to_actions#index", defaults: { format: 'json' }
      get "calltoaction/show" => "call_to_actions#show", defaults: { format: 'json' }
    end
  end

  match "/update_calltoaction_content", :to => "call_to_action#update_calltoaction_content", defaults: { format: 'json' }
  match "/calltoaction_overvideo_end", :to => "call_to_action#calltoaction_overvideo_end", defaults: { format: 'json' }
  match "/update_play_interaction", :to => "call_to_action#update_play_interaction", defaults: { format: 'json' }

  # error handling
  match "/404", :to => "http_error#not_found_404"
  match "/500", :to => "http_error#internal_error_500"
  match "/422", :to => "http_error#unprocessable_entity_422"

  match "rss", :to => "rss#global_rss", defaults: { format: 'rss' }

  match "/extra", :to => "property#extra"

  match "profile", :to => "profile#show"
  match "rss", :to => "rss#property_rss", defaults: { format: 'rss' }
  match "check_level_and_badge_up", :to => "call_to_action#check_level_and_badge_up", defaults: { format: 'json' }
  resources :call_to_action do
    match "/add_comment", :to => "call_to_action#add_comment"
    match "/get_comment_published", :to => "call_to_action#get_comment_published", defaults: { format: 'json' }
    match "/get_closed_comment_published", :to => "call_to_action#get_closed_comment_published", defaults: { format: 'json' }
    match "/next_disqus_page", :to => "call_to_action#next_disqus_page", defaults: { format: 'json' }
    match "/get_overvideo_interaction", :to => "call_to_action#get_overvideo_interaction"
  end

  root :to => "application#index"

end
