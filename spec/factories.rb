FactoryGirl.define do
  factory :user do
    first_name 'Test'
    last_name 'User'
    sequence(:email) { |n| "example#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    confirmed_at Time.now
    
    factory :admin do
      after(:create) {|user| user.add_role(:admin)}
    end
    
    factory :subscribed do
      stripe_customer_id 'dummy_value'
    end
  end
end
