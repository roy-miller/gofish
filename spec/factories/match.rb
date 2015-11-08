FactoryGirl.define do
  factory :match do
    id 123
    game 
    match_users
    current_user
    messages
    status = Status::PENDING
  end
end
