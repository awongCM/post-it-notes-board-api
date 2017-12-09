FactoryGirl.define do
  factory :note do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    color { Faker::Lorem.word }
  end
end