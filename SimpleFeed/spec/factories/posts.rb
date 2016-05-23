# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    title { 'New title' } 
    name { 'New name' }
    url { 'http://test.com/' }
    content { 'Content' }
  end

  trait :invalid_post do
    title nil
    name nil
    url nil
    content nil
  end

  trait :invalid_url do
    url 'invalid_url'
  end
end
