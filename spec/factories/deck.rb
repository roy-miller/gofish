FactoryGirl.define do
  # sequence :rank do |n|
  #   %w{2 3 4 5 6 7 8 9 10 J Q K A}[n % 13]
  # end
  # factory :card do
  #   rank
  #   suit 'C'
  # end
  factory :deck do
    cards []
  end
end

# sequence :rank { |n| %w{2 3 4 5 6 7 8 9 10 J Q K A}[n % 13] }
# sequence(:suit, []) do |suit|
# end
