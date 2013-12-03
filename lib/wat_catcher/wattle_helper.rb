module WatCatcher
  module Helper
    def javascript_wat_catcher
      javascript_include_tag "wat_catcher",
                             data: {
                              route: wat_catcher.wats_path,
                              app_name: ::Rails.application.class.parent_name,
                              app_user: wat_user.as_json
                             }
    end
  end
end