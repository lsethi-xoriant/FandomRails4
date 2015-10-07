require 'fandom_utils'
require 'sites/maxibon/utils'
include FandomUtils

Fandom::Application.routes.draw do

  mount RailsAdmin::Engine => '/rails_admin/'

  get '/cookies_policy', :to => 'application#cookies_policy'
  get '/privacy_policy', :to => 'application#privacy_policy'

  get '/sitemap', to: 'sitemap#index', defaults: { format: 'xml' }

  constraints(SiteMatcher.new('braun_ic')) do
    scope module: "sites" do
      scope module: "braun_ic" do
        post "/profile/update_user", to: "profile#update_user", defaults: { format: 'json' }
        get "/concorso", to: "application#contest"
        get "/concorso_identitycollection", to: "application#contest_identitycollection"
        get "/concorso_identitycollection_success", to: "application#contest_identitycollection_success"
        post "/concorso_identitycollection/update", to: "application#contest_identitycollection_update"
        post "/play", :to => "instantwin#play_ticket", defaults: { format: 'json' }
        get "/", to: "application#index"
        get "/tips", to: "application#index_tips"
        get "/call_to_action/:id", to: "application#index"
        get "/call_to_action/:id/:descendent_id", to: "application#index"
        post "/reset_redo_user_interactions", to: "application#reset_redo_user_interactions", defaults: { format: 'json' }
        post "/append_tips", to: "application#append_tips", defaults: { format: 'json' }
        get "/ranking", to: "ranking#show"
        get "/update_ranking_pagination", to: "ranking#update_ranking_pagination", defaults: { format: 'json' }
        devise_scope :user do
          post "/users", :to => "registrations#create"
        end
        namespace :easyadmin do
          post "export_users", :to => "user#export_users"
        end
      end
    end
  end

  constraints(SiteMatcher.new('coin')) do
    get "/play", :to => "instantwin#play_ticket", defaults: { format: 'json' }
    scope module: "sites" do
      scope module: "coin" do
        get "/", to: "application#index"
        get '/privacy_policy', :to => 'application#show_privacy_policy'
        get '/cookies_policy', :to => 'application#show_cookies_policy'
        get '/stores', :to => 'application#show_stores'
        post "profile/complete_for_contest", :to => "application#complete_for_contest", defaults: { format: 'json' }
        devise_scope :user do
          post "/users", :to => "registrations#create"
          get 'auth/:provider/callback', :to => 'sessions#create'
        end
      end
    end
  end

  constraints(SiteMatcher.new('orzoro')) do
    scope module: "sites" do
      scope module: "orzoro" do
        namespace :easyadmin do
          match "/dashboard", :to => "easyadmin#dashboard", via: [:get, :post]
          get "/cups_confirmed", :to => "user#index_cup_requests", defaults: { page: 'confirmed' }
          get "/cups_not_confirmed", :to => "user#index_cup_requests", defaults: { page: 'not_confirmed' }
          match "/cups/filter", :to => "user#filter_cup_requests", via: [:get, :post]
          get "export_cup_requests", :to => "user#export_cup_requests"
        end
        get "/", to: "application#index"
        get "/gadget", to: "cup_redeemer#index"
        get "/gadget/step_1", to: "cup_redeemer#step_1"
        post "/gadget/step_1/update", to: "cup_redeemer#step_1_update"
        get "/gadget/step_2", to: "cup_redeemer#step_2"
        post "/gadget/step_2/update", to: "cup_redeemer#step_2_update"
        get "/gadget/step_3", to: "cup_redeemer#step_3"
        post "/gadget/step_3/update", to: "cup_redeemer#step_3_update"
        get "/gadget/request_completed", to: "cup_redeemer#request_completed"
        get "/complete_registration_from_cups/:email/:token", to: "cup_redeemer#complete_registration", :constraints => { :email => /.*/ }
        get "/complete_registration_from_newsletter/:email/:token", to: "newsletter#complete_registration", :constraints => { :email => /.*/ }
        post "/next_calltoaction", to: "call_to_action#next_calltoaction_in_category", defaults: { format: 'json' }
        post "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
        get "/newsletter/subscribe", :to => "newsletter#subscribe"
        post "/newsletter/subscription_request", :to => "newsletter#send_request"
        get "/newsletter/request_completed", :to => "newsletter#request_completed"

        get "/faq", :to => "application#faq"
        get "/netiquette", :to => "application#netiquette"

        get "/browse", :to => "browse#index"
        
        get "/browse/search", :to => "browse#search"
        get "/browse/autocomplete_search", :to => "browse#autocomplete_search", defaults: { format: 'json' }

        get "/browse/view_recent", :to => "browse#view_all_recent"
        get "/browse/view_recent/load_more", :to => "browse#view_all_recent_load_more"
        get "/browse/index_category_load_more", :to => "browse#index_category_load_more"
        get "/browse/category/:id", :to => "browse#index_category"
        get "/browse/full_search_load_more", :to => "browse#full_search_load_more"
        post "/browse/full_search", :to => "browse#full_search"
        
        #resources :call_to_action, only: :show
        get "/call_to_action/:id", to: "http_error#not_found_404"

        get "/ricette/:id", to: "call_to_action#show"
        get "/ricette", :to => "browse#index", defaults: { tagname: 'ricette' }

        get "/prodotti", :to => "browse#index_category", defaults: { id: 'prodotti' }
        get "/prodotti/:id", to: "call_to_action#show"

        get "/storie/:id", to: "call_to_action#show"
        get "/storie", :to => "browse#index", defaults: { tagname: 'storie' }

        get "/test/:id", to: "call_to_action#show"
        get "/test", :to => "browse#index_category", defaults: { id: 'test' }
        get "/test/:id/:descendent_id", to: "call_to_action#show"

        get "/balli/:id", to: "call_to_action#show"
        get "/balli", :to => "browse#index", defaults: { tagname: 'balli' }

        get "/browse/view_all/:id", :to => "browse#index_category"
        get "/browse/contents/:tagname", :to => "browse#index"

        get "/users/sign_up", to: redirect('/')

        get "/prodotti", :to => "browse#index_category", defaults: { id: 'prodotti' }

        #get '/experience/prodotti/:name', to: redirect('/prodotti/%{name}')
        get '/experience/prodotti', to: redirect('/prodotti')
        get '/experience/home', to: redirect('/')
        get '/experience', to: redirect('/')


      end
    end
  end

  constraints(SiteMatcher.new('disney')) do
    scope module: "sites" do
      scope module: "disney" do

        namespace :easyadmin do
          get "settings/properties", :to => "settings#properties_settings"
          get "settings/properties/save", :to => "settings#save_properties_settings"
        end

        get "/iur", to: "application#iur"
        post "/upload_interaction/create/:cta_id/:interaction_id", :to => "call_to_action#upload", defaults: { format: 'json' }
        post "profile/complete_registration", :to => "profile#complete_registration", defaults: { format: 'json' }
        get "/reward/catalogue", :to => "reward#index"
        post "/browse/full_search", :to => "browse#full_search"
        get "/browse/full_search_load_more", :to => "browse#full_search_load_more"

        devise_scope :user do
          post "/users", :to => "registrations#create"
          put "/users/edit", :to => "registrations#update"
          get "/iur/sign_in", to: "registrations#iur"
          get "/users/sign_in", to: "application#iur"
          get "/users/sign_in_admin", to: "sessions#new"
          get "/users/sign_up", to: "sessions#new"
          post "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
        end

        resources :call_to_action, only: :show
        
        get "ordering_ctas", to: "call_to_action#ordering_ctas" , defaults: { format: 'json' }
        get "rss", :to => "rss#calltoactions", defaults: { format: 'rss' }
        post "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }
        post "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
        get "/", to: "application#index"

      end
    end  
  end
  
  constraints(SiteMatcher.new('intesa_expo')) do
    scope module: "sites" do
      scope module: "intesa_expo" do
        get "/stripe/:name", to: "application#iframe_stripe"
        get "/", to: "application#index"
        get "/live", to: "application#live"
        get "/about", :to => "application#about"
        get "/zerowaste", to: "application#appzerowaste"
        get "/calendar", :to => "calendar#index"
        get "/calendar/:day", :to => "calendar#index"
        get "/calendar/fetch/events", :to => "calendar#fetch_events"
        post "/browse/full_search", :to => "browse#full_search"
        get "/browse/category/:id", :to => "browse#intesa_index_category"
        get "/browse/view_all/:id", :to => "browse#intesa_index_category"
        get "/browse/autocomplete_search", :to => "browse#autocomplete_search", defaults: { format: 'json' }
        get "/call_to_action/:id", to: "call_to_action#show"
      end
    end
  end
          
  constraints(SiteMatcher.new('ballando')) do
    get "/profile", :to => "profile#badges"

    devise_scope :user do
      scope module: "sites" do
        scope module: "ballando" do

          resources :call_to_action

          get "/", to: "application#index"

          post "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }

          get "/captcha", :to => "application#generate_captcha", defaults: { format: 'json' }

          get "/redirect_top_with_cookie", :to => "application#redirect_top_with_cookie"

          get '/users/sign_in', :to => 'sessions#ballando_new'

          get "/users/gigya_socialize_redirect", :to => "application#gigya_socialize_redirect"

          get "/custom_call_to_action/:id/next", :to => "custom_call_to_action#show_next_calltoaction"
          get "/custom_call_to_action/:id", :to => "custom_call_to_action#show"

          get "/refresh_top_window", :to => "application#refresh_top_window"
  
          get "/users/rai/sign_out", :to => "sessions#ballando_destroy"
          post "/users/rai/sign_up/create", :to => "registrations#ballando_create"
          post "/users/rai/sign_in/create", :to => "sessions#ballando_create"
          get "/users/rai/sign_in_from_provider/create", :to => "sessions#ballando_create_from_provider", defaults: { format: 'json' }
  
          get "/profile/widget", :to => "iframe_profile#show"
          get "/carousel/widget", :to => "iframe_carousel#main"
          get "/carousel_footer/widget", :to => "iframe_carousel#footer"
          
          get "/iframe/check", :to => "iframe_check#show"
          get "/iframe/get_check", :to => "iframe_check#get_check_template"
          get "/iframe/do_check", :to => "iframe_check#do_check"

          get "/upload_interaction/new", :to => "upload_interaction#new"
          post "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"

          post "/generate_cover_for_calltoaction", :to => "application#generate_cover_for_calltoaction", defaults: { format: 'json' }
          post "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }
          
          get "/special_guest", :to => "application#redirect_into_special_guest"
          
          post "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

          post "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
          post "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
          get "/new_comments_polling", :to => "call_to_action#new_comments_polling", defaults: { format: 'json' }
          post "/ranking/page", :to => "ranking#get_rank_page"
        end
      end
    end
  end

   constraints(SiteMatcher.new('forte')) do
    get "/profile", :to => "profile#badges"

    devise_scope :user do
      scope module: "sites" do
        scope module: "forte" do

          resources :call_to_action

          get "/captcha", :to => "application#generate_captcha", defaults: { format: 'json' }

          post "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }

          get "/update_reward_calltoactions_in_page", to: "call_to_action#update_reward_calltoactions_in_page", defaults: { format: 'json' }

          get "/", :to => "application#index"

          get "/redirect_top_with_cookie", :to => "application#redirect_top_with_cookie"

          get '/users/sign_in', :to => 'sessions#forte_new'

          get "/users/gigya_socialize_redirect", :to => "application#gigya_socialize_redirect"

          get "/custom_call_to_action/:id/next", :to => "custom_call_to_action#show_next_calltoaction"
          get "/custom_call_to_action/:id", :to => "custom_call_to_action#show"

          get "/refresh_top_window", :to => "application#refresh_top_window"
  
          get "/users/rai/sign_out", :to => "sessions#forte_destroy"
          post "/users/rai/sign_up/create", :to => "registrations#forte_create"
          post "/users/rai/sign_in/create", :to => "sessions#forte_create"
          get "/users/rai/sign_in_from_provider/create", :to => "sessions#forte_create_from_provider", defaults: { format: 'json' }
  
          get "/profile/widget", :to => "iframe_profile#show"
          get "/carousel/widget", :to => "iframe_carousel#main"
          get "/carousel_footer/widget", :to => "iframe_carousel#footer"
          
          get "/iframe/check", :to => "iframe_check#show"
          get "/iframe/get_check", :to => "iframe_check#get_check_template"
          get "/iframe/do_check", :to => "iframe_check#do_check"

          get "/upload_interaction/new", :to => "upload_interaction#new"
          post "/upload_interaction/create/:interaction_id", :to => "call_to_action#upload"

          post "/generate_cover_for_calltoaction", :to => "application#generate_cover_for_calltoaction", defaults: { format: 'json' }
          post "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }
          
          get "/special_guest", :to => "application#redirect_into_special_guest"
          
          post "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

          post "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
          post "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
          get "/new_comments_polling", :to => "call_to_action#new_comments_polling", defaults: { format: 'json' }
        end
      end
    end
  end

  post "/profile/update_user", to: "profile#update_user", defaults: { format: 'json' }

  post "/update_basic_share", :to => "application#update_basic_share_interaction", defaults: { format: 'json' }

  post "/user_cookies", to: "application#user_cookies", defaults: { format: 'json' }

  get "/random_calltoaction", to: "call_to_action#random_calltoaction", defaults: { format: 'json' }

  get "/file_upload_too_large", to: "application#file_upload_too_large"

  get "/redirect_into_iframe_calltoaction/:calltoaction_id", to: "application#redirect_into_iframe_calltoaction"
  get "/facebook_share_page_with_meta/:calltoaction_id", to: "call_to_action#facebook_share_page_with_meta"
  get "/profile/update_avatar", to: "application#update_avatar_image"

  get "/redirect_into_iframe_path", :to => "application#redirect_into_iframe_path"
  
  # deprecated: naming is misleading because the controller will create an ugc, not an upload_interaction. Use /ugc/create instead
  post "/upload_interaction/create/:cta_id/:interaction_id", :to => "call_to_action#upload", defaults: { format: 'json' }
  post "/ugc/create/:cta_id/:interaction_id",                :to => "call_to_action#upload", defaults: { format: 'json' }
  get "/upload", :to => "call_to_action#upload"
  
  get "/users/autocomplete_search", :to => "browse#autocomplete_user_search", defaults: { format: 'json' }

  get "/browse", :to => "browse#index"
  post "/browse/full_search", :to => "browse#full_search"
  get "/browse/full_search_load_more", :to => "browse#full_search_load_more"
  get "/browse/autocomplete_search", :to => "browse#autocomplete_search", defaults: { format: 'json' }
  get "/browse/redirect/:query", :to => "browse#index"
  get "/browse/view_all/:id", :to => "browse#index_category"
  get "/browse/view_recent", :to => "browse#view_all_recent"
  get "/browse/view_recent/load_more", :to => "browse#view_all_recent_load_more"
  get "/browse/index_category_load_more", :to => "browse#index_category_load_more"
  get "/browse/category/:id", :to => "browse#index_category"
  get "/browse/contents/:tagname", :to => "browse#index"
  get "/browse/search", :to => "browse#search"
  get "/browse/fullscreen", :to => "browse#index_fullscreen"

  get "/gallery", :to => "gallery#index"
  get "/gallery/:id", :to => "gallery#show"
  get "/gallery/how_to/:id", :to => "gallery#how_to"

  # get "/classifica/:id", :to => "ranking#show"
  get "classifiche", :to => "ranking#show_rankings_page"
  get "bootcamp", :to => "ranking#show_vote_rankings_page"
  post "/ranking/page", :to => "ranking#get_rank_page"
  post "/ranking/vote/page", :to => "ranking#get_vote_rank_page"
  get "/ranking/show/:id", :to => "ranking#show_single_rank"
  get "/ranking/vote/:id", :to => "ranking#show_vote_rank"
  
  get "/healthcheck", :to => "health_check#health_check"
  
  get "/profile/superfan_contest", :to => "profile#superfan_contest"
  
  namespace :api do
    namespace :v2 do
      get "/browse", :to => "browse#index", defaults: { format: 'json' }
      get "/browse_stream", :to => "browse#index_stream", defaults: { format: 'json' }
      get "/browse_index", :to => "browse#browse_index", defaults: { format: 'json' }
      get "/browse_index_load_more", :to => "browse#browse_index_load_more", defaults: { format: 'json' }
      get "/index", :to => "application#index", defaults: { format: 'json' }
      get "/index_gallery", :to => "application#index_gallery", defaults: { format: 'json' }
      get "/properties", :to => "application#get_properties", defaults: { format: 'json' }
      get "/index/load_more", :to => "application#load_more_ctas_in_stream", defaults: { format: 'json' }
      get "/users/sign_in", :to => "user#user_sign_in", defaults: { format: 'json' }
      get "/users/sign_up", :to => "user#user_sign_up", defaults: { format: 'json' }
      get "/users/facebook_sign_in", :to => "user#facebook_sign_in", defaults: { format: 'json' }
      get "/call_to_action/get_related", :to => "call_to_action#get_related_ctas", defaults: { format: 'json' }
      post "/call_to_action/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }
      get "/call_to_action/get_single_cta", :to => "call_to_action#get_single_cta", defaults: { format: 'json' }
      get "/call_to_action/redo_test", :to => "call_to_action#redo_test", defaults: { format: 'json' }
      get "/add_comment", :to => "comment#add_comment", defaults: { format: 'json' }
      get "/append_comment", :to => "comment#append_comment", defaults: { format: 'json' }
      get "/captcha", :to => "comment#generate_captcha", defaults: { format: 'json' }
      post "/ugc/create/:cta_id/:interaction_id", :to => "call_to_action#upload", defaults: { format: 'json' }
      get "/catalogue", :to => "application#index_catalogue", defaults: { format: 'json' }
      get "/catalogue/all", :to => "reward#show_all_catalogue", defaults: { format: 'json' }
      get "/catalogue/avaiable", :to => "reward#show_all_available_catalogue", defaults: { format: 'json' }
      get "/catalogue/gained", :to => "reward#show_all_my_catalogue", defaults: { format: 'json' }
      get "/catalogue/buy_reward", :to => "reward#buy_reward_attempt", defaults: { format: 'json' }
      get "/profile", :to => "profile#index", defaults: { format: 'json' }
      get "/profile/badges", :to => "profile#badges", defaults: { format: 'json' }
      get "/profile/levels", :to => "profile#levels", defaults: { format: 'json' }
      get "/profile/avatars", :to => "profile#profile_avatars", defaults: { format: 'json' }
      get "/profile/update_info", :to => "profile#update_profile_info", defaults: { format: 'json' }
      get "/profile/notices", :to => "profile#notices", defaults: { format: 'json' }
      get "/rankings", :to => "profile#rankings", defaults: { format: 'json' }
      get "/rankings/load_more", :to => "profile#load_more_ranking", defaults: { format: 'json' }
    end
  end

  namespace :easyadmin do

    get "/", :to => "easyadmin#index"

    # TAG
    match "tag/filter", :to => "tag#filter", via: [:get, :post]
    get "tag/clone/:id", :to => "tag#clone"
    match "tag/ordering", :to => "tag#ordering", via: [:get, :post]
    match "tag/retag", :to => "tag#retag_tag", via: [:get, :post]
    post "tag/update_updated_at", :to => "tag#update_updated_at"
    get "cta/tag/:id", :to => "tag#tag_cta"
    post "cta/tag/:id/update", :to => "tag#tag_cta_update"

    resources :home_launchers

    resources :tag

    resources :ranking

    resources :vote_ranking

    # USER
    get "user", :to => "user#index_user"
    post "export_users", :to => "user#export_users"
    get "export_winners", :to => "easyadmin#export_winners"
    get "user/show/:id", :to => "user#show_user"
    match "user/filter", :to => "user#filter_user", via: [:get, :post]

    # WINNER
    get "winner", :to => "easyadmin#index_winner"
    post "winner/send_email_to_winner", :to => "easyadmin#send_email_to_winner"

    # CALL TO ACTION
    get "cta", :to => "call_to_action#index_cta"
    match "cta/filter", :to => "call_to_action#filter", via: [:get, :post]
    get "cta/template", :to => "call_to_action#index_cta_template"
    get "cta/to_approve", :to => "call_to_action#index_user_cta_to_be_approved"
    get "cta/approved", :to => "call_to_action#index_user_cta_approved"
    get "cta/not_approved", :to => "call_to_action#index_user_cta_not_approved"
    match "cta/filter_ugc", :to => "call_to_action#filter_ugc", via: [:get, :post]
    post "cta/:id/update_cta_status", :to => "call_to_action#update_cta_status"
    get "cta/new/", :to => "call_to_action#new_cta"
    get "cta/show/:id", :to => "call_to_action#show_cta", :as => :cta_show
    get "cta/show_details/:id", :to => "call_to_action#show_details"
    get "cta/edit/:id/", :to => "call_to_action#edit_cta"
    match "cta/save", :to => "call_to_action#save_cta", via: [:get, :post]
    patch "cta/update", :to => "call_to_action#update_cta"
    post "cta/hide/:id", :to => "call_to_action#hide_cta"
    match "cta/clone/:id", :to => "call_to_action#clone", via: [:get, :post]
    post "cta/update_user_cta_image/:id", :to => "call_to_action#edit_cta"
    post "cta/send_reason_for_not_approving", :to => "call_to_action#send_reason_for_not_approving"

    # PROMOCODE
    get "promocode", :to => "promocode#index_promocode"
    get "promocode/new_promocode", :to => "promocode#new_promocode"
    post "promocode/create_promocode", :to => "promocode#create_promocode"
    
    # PRIZE
    get "reward", :to => "easyadmin_reward#index"
    match "reward/filter", :to => "easyadmin_reward#filter", via: [:get, :post]
    get "reward/show/:id", :to => "easyadmin_reward#show"
    get "reward/edit/:id", :to => "easyadmin_reward#edit"
    get "reward/new", :to => "easyadmin_reward#new"
    post "reward/save", :to => "easyadmin_reward#save"
    patch "reward/update", :to => "easyadmin_reward#update"
    get "reward/clone/:id", :to => "easyadmin_reward#clone"
    
    # INSTANT WIN
    get "contest", :to => "easyadmin#index_contest"
    get "contest/new", :to => "easyadmin#new_contest"
    get "contest/edit", :to => "easyadmin#edit_contest"
    post "contest/save", :to => "easyadmin#save_contest"
    get "periodicity/new", :to => "easyadmin#new_periodicity"
    post "periodicity/save", :to => "easyadmin#save_periodicity"
    get "periodicity", :to => "easyadmin#index_periodicity"
    post "instantwin/generate/:id", :to => "instantwin#create_wins"
    get "instantwin_prize", :to => "easyadmin#index_prize"
    get "instantwin_prize/new", :to => "easyadmin#new_prize"
    get "instantwin_prize/edit/:id", :to => "easyadmin#edit_prize"
    post "instantwin_prize/save", :to => "easyadmin#save_prize"
    patch "instantwin_prize/update", :to => "easyadmin#update_prize"
    
    # COMMENT
    match "comments/approved", :to => "comments#index_comment_approved", via: [:get, :post]
    match "comments/to_approved", :to => "comments#index_comment_to_be_approved", via: [:get, :post]
    match "comments/not_approved", :to => "comments#index_comment_not_approved", via: [:get, :post]
    match "comments/ugc_approved", :to => "comments#index_comment_approved", :cta => "user_call_to_actions", via: [:get, :post]
    match "comments/ugc_to_approved", :to => "comments#index_comment_to_be_approved", :cta => "user_call_to_actions", via: [:get, :post]
    match "comments/ugc_not_approved", :to => "comments#index_comment_not_approved", :cta => "user_call_to_actions", via: [:get, :post]
    post "comments/:comment_id/update_comment_status", :to => "comments#update_comment_status"

    match "dashboard", :to => "easyadmin#dashboard", via: [:get, :post]
    get "published", :to => "easyadmin#published"
    post "dashboard/get_current_month_event", :to => "easyadmin#get_current_month_event", defaults: { format: 'json' }
    post "dashboard/update_activated_at", :to => "call_to_action#update_activated_at", defaults: { format: 'json' }
    get "most_clicked_interactions", :to => "easyadmin#index_most_clicked_interactions"
    get "reward_cta_unlocked", :to => "easyadmin#index_reward_cta_unlocked"
    
    get "events", :to => "easyadmin_event_console#index"
    match "events/filter", :to => "easyadmin_event_console#apply_filter", defaults: { format: 'json' }, via: [:get, :post]
    
    get "notices", :to => "easyadmin_notice#index"
    get "notices/new", :to => "easyadmin_notice#new"
    post "notices/create", :to => "easyadmin_notice#create"
    get "notices/filter", :to => "easyadmin_notice#apply_filter", defaults: { format: 'json' }
    get "notices/resend_notice/:notice_id", :to => "easyadmin_notice#resend_notice"
    
    get "rules", :to => "easyadmin_rewarding_rules#index"
    post "rules/save", :to => "easyadmin_rewarding_rules#save"
    
    # SETTING
    get "settings/browse", :to => "settings#browse_settings"
    post "settings/browse/save", :to => "settings#save_browse_settings"
    get "settings/ranking", :to => "settings#ranking_settings"
    post "settings/ranking/save", :to => "settings#save_ranking_settings"
    get "settings/notifications", :to => "settings#notifications_settings"
    post "settings/notifications/save", :to => "settings#save_notifications_settings"
    get "settings/profanities", :to => "settings#profanities_settings"
    post "settings/profanities/save", :to => "settings#save_profanities_settings"
    get "settings/instagram_subscriptions", :to => "settings#instagram_subscriptions_settings"
    post "settings/instagram_subscriptions/save", :to => "settings#save_instagram_subscriptions_settings"
    get "/settings/clear_cache", :to => "cache#clear_cache"
  end

  get '/facebook_app', to: "application#facebook_app"

  post '/next_interaction', to: "call_to_action#next_interaction", defaults: { format: 'json' }
  get '/check_next_interaction', to: "call_to_action#check_next_interaction", defaults: { format: 'json' }
  
  # Reward
  get "/reward/catalogue", :to => "reward#index"
  get "/reward/catalogue/all", :to => "reward#show_all_catalogue"
  get "/reward/catalogue/available/all", :to => "reward#show_all_available_catalogue"
  get "/reward/catalogue/my/all", :to => "reward#show_all_my_catalogue"
  get "/reward/show/:reward_id", :to => "reward#show"
  post "/reward/buy", :to => "reward#buy_reward_attempt", defaults: { format: 'json' }
  get "/reward/how_to", :to => "reward#how_to"

  # Captcha.
  get "/captcha", :to => "captcha#generate_captcha", defaults: { format: 'json' }

  # Instagram subscribe.
  post "/save_instagram_upload_object/:interaction_id/:subscription_id/:tag_name", :to => "application#save_instagram_upload_object"
  post "/modify_instagram_upload_object/:interaction_id/:tag_name", :to => "application#modify_instagram_upload_object"
  match "/instagram_new_tagged_media_callback", :to => "callback#instagram_new_tagged_media_callback", defaults: { format: 'json' }, via: [:get, :post]

  # Facebook callback
  match "/facebook_page_feed_callback", :to => "callback#facebook_page_feed_callback", defaults: { format: 'json' }, via: [:get, :post]

  get "/how_to", :to => "application#how_to"
  get "/landing", :to => "landing#index"

  get "profile", :to => "profile#index"
  get "profile/rankings", :to => "profile#rankings"
  get "profile/rewards", :to => "profile#rewards"
  get "profile/notices", :to => "profile#notices"
  get "profile/levels", :to => "profile#levels"
  get "profile/badges", :to => "profile#badges"
  get "profile/prizes", :to => "profile#prizes"
  post "profile/notices/mark_as_read", :to => "notice#mark_as_read", defaults: { format: 'json' }
  post "profile/notices/mark_all_as_read", :to => "notice#mark_all_as_read", defaults: { format: 'json' }
  post "profile/notices/mark_as_viewed", :to => "notice#mark_as_viewed", defaults: { format: 'json' }
  post "profile/notices/mark_all_as_viewed", :to => "notice#mark_all_as_viewed", defaults: { format: 'json' }
  get "profile/notices/get_recent_notice", :to => "notice#get_user_latest_notices", defaults: { format: 'json' }
  get "profile/remove-provider/:provider", :to => "profile#remove_provider"
  post "profile/complete_for_contest", :to => "profile#complete_for_contest", defaults: { format: 'json' }

  get "/sign_in_fb_from_page", :to => "application#sign_in_fb_from_page"
  get "/sign_in_tt_from_page", :to => "application#sign_in_tt_from_page"
  get "/sign_in_simple_from_page", :to => "application#sign_in_simple_from_page"

  get "/playticket", :to => "instantwin#play_ticket_mb"
  post "/play", :to => "instantwin#play_ticket", defaults: { format: 'json' }
  get "/winners", :to => "instantwin#show_winners"

  get "/anchor_provider_from_calltoaction/:calltoaction_id", to: "application#anchor_provider_from_calltoaction"

  devise_for :users, :controllers => { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords" }

  devise_scope :user do
    get "/password_feedback", :to => "passwords#feedback"
    get "/users/sign_in", :to => "sessions#create", :as => "user_sign_in"
    get "/users/sign_out", :to => "sessions#destroy"
    get "auth/:provider/callback", :to => "sessions#create"
    get "/auth/failure" => "sessions#omniauth_failure"
    get "/profile/edit", :to => "registrations#edit"
    get "/user/sign_in_as/:id", :to => "sessions#sign_in_as"
  end

  post "/user_event/update_answer", :to => "call_to_action#update_answer", defaults: { format: 'json' }
  post "/user_event/update_download", :to => "call_to_action#update_download", defaults: { format: 'json' }
  post "/user_event/update_like", :to => "call_to_action#update_like", defaults: { format: 'json' }
  post "/user_event/update_check", :to => "call_to_action#update_check", defaults: { format: 'json' }
  get "/user_event/share/:provider", :to => "call_to_action#share", defaults: { format: 'json' }
  get "/user_event/share_free/:provider", :to => "call_to_action#share_free", defaults: { format: 'json' }

  get "/gallery", :to => "gallery#index"

  post "/update_call_to_action_in_page_with_tag", :to => "application#update_call_to_action_in_page_with_tag", defaults: { format: 'json' }

  post "/update_calltoaction_content", :to => "call_to_action#update_calltoaction_content", defaults: { format: 'json' }
  get "/calltoaction_overvideo_end", :to => "call_to_action#calltoaction_overvideo_end", defaults: { format: 'json' }
  post "/update_interaction", :to => "call_to_action#update_interaction", defaults: { format: 'json' }

  get "/delete_current_user_interactions", :to => "application#delete_current_user_interactions"

  get "rss", :to => "rss#rss", defaults: { format: 'rss' }

  post "/append_calltoaction", :to => "call_to_action#append_calltoaction", defaults: { format: 'json' }
  post "/last_linked_calltoaction", to: "call_to_action#last_linked_calltoaction", defaults: { format: 'json' }

  post "/add_comment", :to => "call_to_action#add_comment", defaults: { format: 'json' }
  post "/append_comments", :to => "call_to_action#append_comments", defaults: { format: 'json' }
  post "/comments_polling", :to => "call_to_action#comments_polling", defaults: { format: 'json' }

  get "rss", :to => "rss#property_rss", defaults: { format: 'rss' }
  get "check_level_and_badge_up", :to => "call_to_action#check_level_and_badge_up", defaults: { format: 'json' }
  get "get_overvideo_during_interaction", :to => "call_to_action#get_overvideo_during_interaction", defaults: { format: 'json' }
  
  get "/call_to_action/:id/:descendent_id", to: "call_to_action#show"

  resources :call_to_action, only: :show
  #resources :call_to_action, only: :show do
  #  get "/next_disqus_page", :to => "call_to_action#next_disqus_page", defaults: { format: 'json' }
  #end

  get "/newsletter_unsubscribe/:email/:security_token", :to => "newsletter#unsubscribe", :constraints => { :email => /.*/ }
  get "email_notifications_unsubscribe/:username/:security_token", :to => "notice#unsubscribe", :constraints => { :username => /.*/ }

  post "/reset_redo_user_interactions", to: "call_to_action#reset_redo_user_interactions", defaults: { format: 'json' }

  # ICAL
  get "/ical/:interaction_id/:name", to: "calendar#get_ical", defaults: { format: 'ics' }

  get "/tag/:name", :to => "application#index"
  root :to => "application#index"

  # error handling
  get "/404", :to => "http_error#not_found_404"
  get "/500", :to => "http_error#internal_error_500"
  get "/422", :to => "http_error#unprocessable_entity_422"

end
