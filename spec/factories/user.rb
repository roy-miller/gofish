require_relative '../../lib/robot_user.rb'

FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "user#{n}" }

    factory :robot_user, class: RobotUser, parent: :user do
      think_time 0

      trait :fast_thinker do
        think_time 0.25
      end

      trait :thinker do
        think_time 2.5
      end

      trait :slow_thinker do
        think_time 10
      end

      after(:create) do |robot, evaluator|
        robot.name = "robot#{robot.id}"
        robot.save
      end
    end
  end
end
