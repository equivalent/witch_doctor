# Witch Doctor ActionModel::Serializer


The reason why the gem is not using [ActiveModel::Serializer](https://github.com/rails-api/active_model_serializers)
by default is that I didn't want to introduce extra dependencies.
This engine is trying to relly just on the native Rails library for
generating JSON and be as simple as possible.

However with few copy-paste configuration it works
allong `ActionModel::Serializer` as well.

## How to

create serializer

```ruby
# app/seriazizers/virus_scan_serializer.rb
class VirusScanSerializer < ActiveModel::Serializer
  attributes :id, :scan_result, :scanned_at, :file_url

  def file_url
    object.file_url
  end

  def scanned_at
    object.scanned_at.try(:utc).try(:iso8601)
  end
end
```

create controller hash generator

```ruby
# lib/witch_doctor/object_hash_generator_for_serializer.rb
module WitchDoctor
  class ObjectHashGeneratorForSerializer
    def call(object)
      if object.respond_to?(:each)
        { json: object, root: "data", each_serializer: VirusScanSerializer }
      else
        { json: object, root: "data", serializer: VirusScanSerializer }
      end
    end
  end
end
```

in `wich_doctor` initializer tell it to use serializer when rendering json object

```ruby
# config/initializers/witch_doctor.rb

# ...
WitchDoctor.controller_object_hash_generator = WitchDoctor::ObjectHashGeneratorForSerializer.new
```


**Please don't forget to write a request test in your app*
