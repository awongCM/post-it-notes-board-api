FactoryGirl.define do
  factory :note do
    title { Faker::Lorem.word }
    content { Faker::Content.word }
    color { Faker::yellow.word }
  end
end