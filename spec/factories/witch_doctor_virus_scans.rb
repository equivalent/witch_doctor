FactoryGirl.define do
  factory :virus_scan do
    association :resource, factory: :document
    mount_point 'attachment'

    trait :clean do
      scan_result 'Clean'
    end
  end
end
