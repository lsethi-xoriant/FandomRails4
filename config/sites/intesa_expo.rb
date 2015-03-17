module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'intesa_expo', 
      domains: ['intesa-expo.fandom.localdomain', 'intesa-expo.live.fandomlab.com', 'intesa-expo.dev.fandomlab.com'],
      assets_precompile: ['intesa_expo_application.css', 'intesa_expo_application.js', 'intesa_expo_ie9.css'],
      periodicity_kinds: [PERIOD_KIND_DAILY],
      allowed_context_roots: ["it", "en"],
      anonymous_interaction: true,
      free_provider_share: true,
      init_ctas: 3
    )      
  end
end

