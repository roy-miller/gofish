FactoryGirl.define do
  factory :robot_user do
    think_time 0
  end

  trait :thinker do
    think_time 2.5
  end

  trait :slow_thinker do
    think_time 10
  end
end
