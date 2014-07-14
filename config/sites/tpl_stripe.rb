module Fandom
  class Application < Rails::Application
    register_fandom_site(
      id: 'tpl_stripe', 
      title: 'TPL Stripe',
      domains: ['tpl-stripe.fandom.localdomain', 'tpl-stripe.shado.tv', 'tpl-stripe.stage.fandomlab.com'],
      share_db: 'fandom',
      assets_precompile: ['tpl_stripe_application.css', 'tpl_stripe_application.js'],
    )
  end
end
