[![Build Status](https://travis-ci.org/equivalent/witch_doctor.svg)](https://travis-ci.org/equivalent/witch_doctor)
[![Code Climate](https://codeclimate.com/github/equivalent/witch_doctor/badges/gpa.svg)](https://codeclimate.com/github/equivalent/witch_doctor)
[![Test Coverage](https://codeclimate.com/github/equivalent/witch_doctor/badges/coverage.svg)](https://codeclimate.com/github/equivalent/witch_doctor)

# Witch Doctor

Rails engine that provides simple API so that external antivirus
script can pull down files that need to be scanned and update their
results.


Engine was designed to work alongside [virus_scan_service gem](https://github.com/equivalent/virus_scan_service),
to which it provides a list of VirusScans. These are created upon file resource
create / update events.

API is trying to comply with [JSON API standard](http://jsonapi.org/)

## CarrierWave

gem is by default assuming you use [Carriewave
gem](https://github.com/carrierwaveuploader/carrierwave)
however it's not a dependancy as long as `:mount_point` responds to
`url` call (look at `spec/dummy/app/models/document.rb`) for more
details

## working along `ActiveModel::Serializer`

The reason why the gem is not using [ActiveModel::Serializer](https://github.com/rails-api/active_model_serializers)
by default is that I didn't want to introduce extra dependencies.
This engine is trying to be really lightweight.

If you choose to use it in application using ActiveModel::Serializer you should have no problems.

# Setup

In your application:

```ruby
# Gemfile

# ...
gem 'witch_doctor'

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

WitchDoctor.token = Rails
  .application
  .secrets
  .fetch('antivirus_scan')
  .fetch('token')
```


```sh
bundle install
rake db:migrate
```

## Optional

**Add helper**

```ruby
# app/helpers/application_helper.rb
include WitchDoctor::ApplicationHelper
```

after this you can use the `antivirus` helper

```haml
= antivirus(@document, :attachment) do
  - link_to @document.attachment_name, @document.attachment.url
```

This will show the link when `VirusScan` for `@document` is `Clean`


# Overiding WitchDoctor Examples

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

## extending Antivirus helper

```ruby
include WitchDoctor::ApplicationHelper
module ApplicationHelper
  alias_method :antivirus_without_view_requirement_respect, :antivirus
  alias_method :antivirus, :antivirus_with_view_requirement_respect

  def antivirus_with_view_requirement_respect(decorated_resource, mount_point)
    if decorated_resource.send("view_requires_#{mount_point}_virus_check?")
      antivirus_without_view_requirement_respect(decorated_resource, mount_point)
    else
      yield
    end
  end
end
```

# Testing

Make sure you turn of `virus_scan_scheduling_on` option so that gem wont
create extra records when your tests are running

```
# config/initializers/witch_doctor.rb
WitchDoctor.skip_virus_scan_scheduling = true
```

turn it on only when needed

```ruby
# spec/request/virus_scan.rb

# ...
before do
  WitchDoctor.skip_virus_scan_scheduling = false
end

after do
  WitchDoctor.skip_virus_scan_scheduling = true
end

# ...
```

The gem/engine is pretty well tested but I recomend to write
interation test for every application it is introduced to.

Example with RSpec request test:

```ruby
require 'spec_helper'

RSpec.describe 'VirusScans', :type => :request do

  before(:all) { WitchDoctor.time_stamper = -> { Time.now.midnight } }
  after(:all)  { WitchDoctor.time_stamper = (reset_stamper_to_default = nil) }

  let(:token) { '1234' }
  let!(:virus_scan) { FactoryGirl.create(:document).virus_scans.last }

  describe 'GET index' do
    before do
      get "/wd/virus_scans", token: token, format: 'json'
    end

    it 'responds with success' do
      expect(response.status).to be 200
    end

    it 'expect the JSON response to be JSON API hash' do
      expect(JSON.parse response.body).to eq({
        "data" => [
          {
            "id" => virus_scan.id,
            "scan_result" => nil,
            "scanned_at" => nil,
            "file_url" => "/uploads/documents/#{virus_scan.id}/passport.jpg" # don't care about file storage (tests)
                                                                             # as virus scans are needed only on s3
          }
        ]
      })
    end
  end

  describe 'PUT update' do
    let(:virus_scan_params) { { scan_result: 'Clean' } }

    before do

      put "/wd/virus_scans/#{virus_scan.id}",
        { format: 'json', virus_scan: virus_scan_params },
        { 'Authorization' => "Token 1234" }
    end

    it 'responds with success' do
      expect(response.status).to be 200
    end

    it 'expect to update existing virus_scan' do
      expect(JSON.parse response.body).to eq({
        "data" => {
          "id" => virus_scan.id,
          "scan_result" => 'Clean',
          "scanned_at" => Time.now.midnight.utc.iso8601,
          "file_url" => "/uploads/documents/#{virus_scan.id}/passport.jpg"
        }
      })
    end
  end
end
```
