# -*- encoding : utf-8 -*-
# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    sequence(:commenter) { |n| "Commenter#{n}" } 
    sequence(:body) { |n| "New body#{n}" } 
  end
end
