FactoryGirl.define do
  factory :document do
    trait :with_attachment do
      attachment 'blank_pdf.pdf'
    end
  end
end
