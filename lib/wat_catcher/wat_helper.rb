module WatCatcher
  module Helper
    def watch_watcher_url
      "#{WatCatcher.configuration.host}/assets/wat_catcher.js"
    end
    def javascript_include_wat_catcher
      "<script src='#{watch_watcher_url}' type='text/javascript'></script>".html_safe
    end
  end
  ActionView::Base.send :include, Helper if defined?(ActionView::Base)
end