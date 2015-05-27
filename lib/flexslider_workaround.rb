require "flexslider/version"

module Flexslider
  module Rails
    class Engine < ::Rails::Engine
      initializer :append_dependent_assets_path, :group => :all do |app|
        app.config.assets.precompile += ['flexslider.css', 'jquery.flexslider.js', 'fonts/flexslider-icon.eot', 'fonts/flexslider-icon.svg', 'fonts/flexslider-icon.ttf', 'fonts/flexslider-icon.woff']
      end
    end
  end
end