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

    def javascript_bugsnag_catcher
      javascript_include_tag "bugsnag",
                             data: {
                               endpoint: wat_catcher.bugsnag_path(::Rails.application.class.parent_name),
                               apiKey: "a"*32,
                               user: wat_user.as_json,
                               notifyUnhandledRejections: !!WatCatcher.configuration.notify_unhandled_promise_rejections
                             }
    end
  end
end
