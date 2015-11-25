FactoryGirl.define do
  factory :robot_user do
    think_time 1
  end

  trait :slow_thinker do
    think_time 10
  end
end
