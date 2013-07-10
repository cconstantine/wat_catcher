module WatCatcher
  module Helper
    def javascript_wat_catcher
      javascript_include_tag "wat_catcher", "data-host" => WatCatcher.configuration.host, "data-app_env" => ::Rails.env, "data-app_name" => ::Rails.application.class.parent_name
    end
  end
end