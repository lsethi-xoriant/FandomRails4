module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'intesa_expo', 
      domains: ['intesa-expo.fandom.localdomain', 'intesa-expo.live.fandomlab.com', 'intesa-expo.dev.fandomlab.com', 'intesa-expo.stage.fandomlab.com', 'expo2015.intesasanpaolo.com', 'expo.intesasanpaolo.com', 'imprese.unmondopossibile.com', 'www.expo2015.intesasanpaolo.com', 'www.expo.intesasanpaolo.com', 'www.imprese.unmondopossibile.com', 'www.italiadalvivo.com', 'italiadalvivo.com'],
      assets_precompile: ['intesa_expo_application.css', 'intesa_expo_application.js', 'intesa_expo_ie9.css'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      interactions_for_anonymous: ["share", "play", "download", "link"],
      allowed_context_roots: ["it", "en", "imprese", "inaugurazione"], # it and and are expo properties
      default_property: "it",
      free_provider_share: true,
      init_ctas: 3,
      is_tag_filter_exclusive: true
    )      
  end
end

