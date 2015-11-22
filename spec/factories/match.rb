FactoryGirl.define do
  factory :match do
    id 123
    messages []
    status MatchStatus::PENDING
    users []
    current_user nil

    initialize_with { new(users) }
  end
end
