# WatCatcher

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'wat_catcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wat_catcher

## Usage

### Configuration
You can configure the wat_catcher in 2 ways; 1) via a config/wat_catcher.yml file or in ruby.

Currently there are only 2 configuration options:
host: This is the beginning of the url used to post wats to wattle.  It should look something like "https://yourwattleserver.com".
disabled: If truthy this will stop any wats from being posted.

Here are 2 identical configs specified in the yml and in ruby.

config/wat_catcher.yml
```yml
production: &default
  host: "https://wattle.yourhost.com"

development:
  <<: *default
  disabled: true

test:
  <<: *default
  disabled: true
```

OR

config/application.rb
```ruby
module YourApp
  class Application < Rails::Application
    WatCatcher.configuration.host =  "https://wattle.yourhost.com"
  end
end
```

config/environments/development.rb
```ruby
YourApp::Application.configure do
  WatCatcher.configuration.disabled = true
end
```

config/environments/test.rb
```ruby
YourApp::Application.configure do
  WatCatcher.configuration.disabled = true
end
```


### Mount the engine in your app for javascript errors
To get around cross-origin issues, an engine was created that accepts POSTs of client exceptions and puts a sidekiq
job in to post the wat to wattle.

In your routes.rb:
```ruby
YourApp::Application.routes.draw do
  mount WatCatcher::Engine => '/wat_catcher'
end
```

### Integrating with a controller

Posting errors from a controller action is done by simply including the CatcherOfWats concern into your controller
```ruby
class ApplicationController < ActionController::Base
  include WatCatcher::CatcherOfWats
end
```

That will install an around_filter that reports and re-raises anything raised in an action.

If you want to record some info about what user saw the error simply implement a 'wat_user' method on the controller
```ruby
class ApplicationController < ActionController::Base

  def wat_user
    {id: logged_in? ? "account_#{current_user.id}" : nil }
  end

end
```

The wat_user will be turned into a json object.  You may put any field in the wat_user, but the 'id' field will be used
by wattle to decide how many unique users have seen an exception.

### Integrating with sidekiq

To have sidekiq post exceptions from sidekiq jobs you must install the sidekiq middleware:
```ruby
::Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add ::WatCatcher::SidekiqMiddleware
  end
end
```

If you want to some info about what user saw the error you need to implement a 'wat_user' method on the worker.  The user
object returned by this wat_user follows the same rules as the wat_user on a controller, but the way it's called is
more complicated.

Whatever method is being called by sidekiq to start the job, make sure it implements a wat_user method that accepts
the same arguments.

Here are some ways that a wat_user method could be implemented:
```ruby
class SomeModel < ActiveRecord::Base
  belongs_to :account
  class << self
    def notify(some_model_id)
      SomeModel.find(some_model_id).some_delayed_method
    end

    def wat_user(some_model_id)
    { id: "some_model_#{some_model_id}" }
    end
  end


  def wat_user(*args)
    { id: "some_model_#{id}" }
  end

  def some_delayed_method
    raise 'herp'
  end

  def some_other_delayed_method(an_arg)
    raise 'derp'
  end

end

# Queuing on SomeModel like the following should generate a wat_user with a reasonable id.
SomeModel.last.delay.some_delayed_method
SomeModel.last.delay.some_other_delayed_method('blarg')
SomeModel.delay.notify(12)


class SomeWorker
  include Sidekiq::Worker

  def perform(some_arg)
    raise "wat? #{some_arg}"
  end

  def wat_user(some_arg)
    { id: "SomeWorker: #{some_arg}" }
  end
end

# The queued job will raise an error and register a wat with the user "SomeWorker: derp"
SomeWorker.perform_async("derp")
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
