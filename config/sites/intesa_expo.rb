module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'intesa_expo', 
      domains: ['intesa-expo.fandom.localdomain', 'intesa-expo.live.fandomlab.com', 'intesa-expo.dev.fandomlab.com', 'intesa-expo.stage.fandomlab.com', 'expo2015.intesasanpaolo.com', 'expo.intesasanpaolo.com', 'imprese.unmondopossibile.com', 'www.expo2015.intesasanpaolo.com', 'www.expo.intesasanpaolo.com', 'www.imprese.unmondopossibile.com'],
      assets_precompile: ['intesa_expo_application.css', 'intesa_expo_application.js', 'intesa_expo_ie9.css'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      allowed_context_roots: ["it", "en", "imprese"],
      anonymous_interaction: true,
      free_provider_share: true,
      init_ctas: 3
    )      
  end
end

