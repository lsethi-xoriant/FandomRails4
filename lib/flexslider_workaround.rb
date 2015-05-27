require "flexslider/version"

module Flexslider
  module Rails
    class Engine < ::Rails::Engine
      initializer :append_dependent_assets_path, :group => :all do |app|
        app.config.assets.paths += %w( )

        app.config.assets.precompile += %w( flexslider.css )
        app.config.assets.precompile += %w( jquery.flexslider.js )

        app.config.assets.precompile += %w( flexslider-icon.eot )
        app.config.assets.precompile += %w( flexslider-icon.svg )
        app.config.assets.precompile += %w( flexslider-icon.ttf )
        app.config.assets.precompile += %w( flexslider-icon.woff )
      end
    end
  end
end