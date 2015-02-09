# Witch Doctor

Rails engine that provides simple API so that external antivirus
script can pull down files that need to be scaned and update their
results.


Engine was designed to work along [virus_scan_service gem](https://github.com/equivalent/virus_scan_service), 
to witch it provide list of VirusScans, that are created upon resource 
create / update that change a file.


## CarrierWave

gem is by default assuming you use [Carriewave
gem](https://github.com/carrierwaveuploader/carrierwave)
however it's not a dependancy as long as `:mount_point` responds to
`url` call (look at `spec/dummy/app/models/document.rb`) for more
details


# Setup

In your application:

```ruby
# Gemfile

# ...
gem 'witch_doctor', github: 'equivalent/witch_doctor'

```

```ruby
# config/routes.rb
MyCoolApplication::Application.routes.draw do
  mount WitchDoctor::Engine => "/wd", :as => "witch_doctor"
  # ...
end
```

```ruby
# /config/initializers/witch_doctor.rb

VirusScan.token = Rails
  .application
  .secrets
  .fetch('antivirus_scan')
  .fetch('token')
```

```sh
bundle install
rake db:migrate
```


## extending controller

```ruby
module WitchDoctor
  module MyAppControllerExtension
    def self.included(base)
      base.force_ssl unless: :development?
      base.skip_before_filter :do_stuff
    end

    def development?
      Rails.env.in? ['test', 'development']
    end
  end
end
WitchDoctor::VirusScansController.send(:include,WitchDoctor::MyAppControllerExtension)
```
