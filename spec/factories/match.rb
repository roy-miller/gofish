FactoryGirl.define do
  factory :match do
    status MatchStatus::PENDING
    users { [] }
    #association :game, factory: :game, strategy: :build
    initialize_with { new({users: users}) }

    trait :users_have_no_cards do
      after(:build) do |match|
        match.users.each { |user| match.player_for(user).hand = [] }
      end
    end
  end
end
