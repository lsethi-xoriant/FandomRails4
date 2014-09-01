module OmniAuth::Strategies

  Rails.configuration.deploy_settings["sites"].each do |tenant_id, values|
    authentications = values.fetch("authentications", [])
    authentications.each do |authentication_name, authentication_app_data|

      authentication_model = Object.const_get("OmniAuth").const_get("Strategies").const_get(authentication_name.camelcase)

      new_authentication_class = Class.new(authentication_model) do
        cattr_accessor :tenant_id do tenant_id end
        cattr_accessor :authentication_name do authentication_name end

        def name
          "#{self.authentication_name}_#{self.tenant_id}".to_sym
        end
      end

      OmniAuth::Strategies.const_set("#{authentication_name.camelcase}#{tenant_id.camelcase}", new_authentication_class)

      Rails.application.config.middleware.use OmniAuth::Builder do
        provider "#{authentication_name}_#{tenant_id}".to_sym, authentication_app_data["app_id"], authentication_app_data["app_secret"], 
                 :scope => authentication_app_data["scope"]
      end

    end
  end

end

OmniAuth.config.on_failure = Proc.new { |env| [302, { 'Location' => "/auth/failure", 'Content-Type'=> 'text/html' }, []] }
