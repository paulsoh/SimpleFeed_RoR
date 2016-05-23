# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    title 'Test title'
    name 'Test name'
    url 'http://test.com'
    content 'Test content Test content'
  end

  trait :invalid_url do
    url 'invalid_url'
  end
end
