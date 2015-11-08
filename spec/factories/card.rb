i = 1
hash = Hash.new
['S','C','H','D'].each do |suit|

end

FactoryGirl.define do
  sequence :rank { |n| %w{2 3 4 5 6 7 8 9 10 J Q K A}[n % 13] }
  sequence(:suit, []) do |suit|

  end
  factory :card do
    rank
    suit 'C'
  end
end
