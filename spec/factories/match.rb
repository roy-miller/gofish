FactoryGirl.define do
  factory :match do
    id 123
    messages []
    status MatchStatus::PENDING
    users []
    current_user nil
    #association :game, factory: :game, strategy: :build

    initialize_with { new(users) }

    trait :users_have_no_cards do
      after(:build) do |match|
        match.users.each { |user| match.player_for(user).hand = [] }
      end
    end
  end
end
