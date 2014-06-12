require 'fandom_utils'
require 'sites/maxibon/utils'
include FandomUtils

Fandom::Application.routes.draw do

  use_doorkeeper

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # TODO: Maxibon youtube widget url
  match "/youtube", :to => "youtube_widget#index"

  namespace :easyadmin do
    match "/", :to => "easyadmin#dashboard"

    match "winner", :to => "easyadmin#index_winner"
    match "winner/send_email_to_winner", :to => "easyadmin#send_email_to_winner"

    match "user/show/:id", :to => "easyadmin#show_user"

    match "cta", :to => "easyadmin#index_cta"
    match "cta/filter/:filter", :to => "easyadmin#filter_cta"
    match "cta/filter/:filter/:property", :to => "easyadmin#filter_cta"
    match "cta/new/:property", :to => "easyadmin#new_cta"
    match "cta/show/:id", :to => "easyadmin#show_cta"
    match "cta/edit/:id/:property", :to => "easyadmin#edit_cta"
    match "cta/save", :to => "easyadmin#save_cta"
    match "cta/update", :to => "easyadmin#update_cta"
    match "cta/hide/:id", :to => "easyadmin#hide_cta"
    match "cta/:property", :to => "easyadmin#index_cta"

    match "tag", :to => "easyadmin#index_tag"
    match "tag/edit/:id", :to => "easyadmin#edit_tag"
    match "tag/edit/:id/update", :to => "easyadmin#update_tag"
    match "cta/tag/:id", :to => "easyadmin#tag_cta"
    match "cta/tag/:id/update", :to => "easyadmin#tag_cta_update"

    match "promocode", :to => "easyadmin#index_promocode"
    match "promocode/new_promocode", :to => "easyadmin#new_promocode"
    match "promocode/create_promocode", :to => "easyadmin#create_promocode"

    # INSTANT WIN
    match "/contest", :to => "easyadmin#index_contest"
    match "/contest/new", :to => "easyadmin#new_contest"
    match "/contest/edit", :to => "easyadmin#edit_contest"
    match "/contest/save", :to => "easyadmin#save_contest"
    match "/periodicity/new", :to => "easyadmin#new_periodicity"
    match "/periodicity/save", :to => "easyadmin#save_periodicity"
    match "/periodicity", :to => "easyadmin#index_periodicity"
    match "/instantwin/generate/:id", :to => "instantwin#create_wins"
    match "/prize", :to => "easyadmin#index_prize"
    match "/prize/new", :to => "easyadmin#new_prize"
    match "/prize/edit/:id", :to => "easyadmin#edit_prize"
    match "/prize/save", :to => "easyadmin#save_prize"
    match "/prize/update", :to => "easyadmin#update_prize"

    match "property", :to => "easyadmin#index_property"
    match "property/new", :to => "easyadmin#new_property"
    match "property/save", :to => "easyadmin#save_property"
    match "property/update", :to => "easyadmin#update_property"
    match "property/edit/:id", :to => "easyadmin#edit_property"
    match "property/show/:id", :to => "easyadmin#show_property"
    
    match "comment/approved", :to => "easyadmin#index_comment_approved"
    match "comment/toapproved", :to => "easyadmin#index_comment_to_be_approved"
    match "comment/notapproved", :to => "easyadmin#index_comment_not_approved"
    match "comment/notapproved/:property", :to => "easyadmin#index_comment_not_approved"
    match "comment/approved/:property", :to => "easyadmin#index_comment_approved"
    match "comment/toapproved/:property", :to => "easyadmin#index_comment_to_be_approved"
    match "comment/:property/update", :to => "easyadmin#update_comment_pubblished"

    match "property/show/:id/save_level", :to => "easyadmin#save_level"
    match "property/show/:id/save_badge", :to => "easyadmin#save_badge"
    match "property/show/:id/new_level", :to => "easyadmin#new_level"
    match "property/show/:id/new_badge", :to => "easyadmin#new_badge"
    match "property/show/:id/edit_level/:level_id", :to => "easyadmin#edit_level"
    match "property/show/:id/edit_badge/:badge_id", :to => "easyadmin#edit_badge"
    match "property/show/:id/edit_level/:level_id/update", :to => "easyadmin#update_level"
    match "property/show/:id/edit_badge/:badge_id/update", :to => "easyadmin#update_badge"

    match "destroy_badge", :to => "easyadmin#destroy_badge"
    match "destroy_level", :to => "easyadmin#destroy_level"

    match "dashboard", :to => "easyadmin#dashboard"
    match "published", :to => "easyadmin#published"
    match "dashboard/get_current_month_event", :to => "easyadmin#get_current_month_event", defaults: { format: 'json' }
    match "dashboard/update_activated_at", :to => "easyadmin#update_activated_at", defaults: { format: 'json' }
    
    match "events", :to => "easyadmin_event_console#index"
    match "events/filter", :to => "easyadmin_event_console#apply_filter", defaults: { format: 'json' }
  end

  constraints(SiteMatcher.new('maxibon')) do
    constraints(MaxibonUtils::Matcher.new) do
      match '', to: redirect("https://www.facebook.com/MaxibonMaxiconoItalia/app_597403706967732")
      match '*path', to: redirect("https://www.facebook.com/MaxibonMaxiconoItalia/app_597403706967732")
    end
  end

  post "/", to: "property#index"

  # Captcha.
  match "/captcha", :to => "calltoaction#code_image"

  # Instagram subscribe. 
  match "/instagram_verify_token_callback", :to => "application#instagram_verify_token_callback"

  match "/how_to", :to => "application#how_to"
  match "/landing", :to => "landing#index"

  match "profile", :to => "profile#index"
  match "profile/levels", :to => "profile#levels"
  match "profile/badges", :to => "profile#badges"
  match "profile/rankings", :to => "profile#rankings"
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

  match "/user_event/update_answer", :to => "calltoaction#update_answer", defaults: { format: 'json' }
  match "/user_event/update_download", :to => "calltoaction#update_download", defaults: { format: 'json' }
  match "/user_event/update_like", :to => "calltoaction#update_like", defaults: { format: 'json' }
  match "/user_event/update_check", :to => "calltoaction#update_check", defaults: { format: 'json' }
  match "/user_event/share/:provider", :to => "calltoaction#share", defaults: { format: 'json' }
  match "/user_event/share_free/:provider", :to => "calltoaction#share_free", defaults: { format: 'json' }

  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create'
        post 'passwords' => 'passwords#create'
      end
      get "user/me" => "users#me", defaults: { format: 'json' }
      get "calltoaction/index" => "calltoactions#index", defaults: { format: 'json' }
      get "calltoaction/show" => "calltoactions#show", defaults: { format: 'json' }
    end
  end

  match "/update_calltoaction_content", :to => "calltoaction#update_calltoaction_content", defaults: { format: 'json' }
  match "/append_calltoaction", :to => "property#append_calltoaction", defaults: { format: 'json' }
  match "/calltoaction_overvideo_end", :to => "calltoaction#calltoaction_overvideo_end", defaults: { format: 'json' }
  match "/update_play_interaction", :to => "calltoaction#update_play_interaction", defaults: { format: 'json' }

  # error handling
  match "/404", :to => "http_error#not_found_404"
  match "/500", :to => "http_error#internal_error_500"
  match "/422", :to => "http_error#unprocessable_entity_422"

  match "rss", :to => "rss#global_rss", defaults: { format: 'rss' }

  match "/extra", :to => "property#extra"

  resources :property, path: "" do
    match "profile", :to => "profile#show"
    match "rss", :to => "rss#property_rss", defaults: { format: 'rss' }
    match "check_level_and_badge_up", :to => "calltoaction#check_level_and_badge_up", defaults: { format: 'json' }
    resources :calltoaction, path: "" do
      match "/add_comment", :to => "calltoaction#add_comment"
      match "/get_comment_published", :to => "calltoaction#get_comment_published", defaults: { format: 'json' }
      match "/get_closed_comment_published", :to => "calltoaction#get_closed_comment_published", defaults: { format: 'json' }
      match "/next_disqus_page", :to => "calltoaction#next_disqus_page", defaults: { format: 'json' }
      match "/get_overvideo_interaction", :to => "calltoaction#get_overvideo_interaction"
    end
  end

  root :to => "application#index"

end
