# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    sequence(:commenter) { |n| "Commenter#{n}" } 
    sequence(:body) { |n| "New body#{n}" } 
  end

  factory :invalid_comment, parent: :comment do
    commenter nil
    body nil
  end

  trait :no_commenter do 
    commenter nil
  end

  trait :no_body do 
    body nil
  end

  trait :long_body do 
    body 'a'*141
  end

  trait :short_body do 
    body 'abcd'
  end
end
