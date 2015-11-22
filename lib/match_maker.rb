class MatchMaker
  def match(user, number_of_players)
    relevant_pending_users = pending_users[number_of_players]
    relevant_pending_users << user
    match = nil
    if (relevant_pending_users.count >= number_of_players)
      match = Match.new(relevant_pending_users.shift(number_of_players))
      start_match(match, user)
    end
    match
  end

  def pending_users
    @pending_users ||= Hash.new {|hash, key| hash[key] = []}
  end

  private

  def start_match(match, user)
    match.start
    match.users.each_with_index { |user, player_id| push("wait_channel_#{user.id}", 'match_start_event', { message: "/matches/#{match.id}/users/#{user.id}" }) }
    MatchClientNotifier.new(match)
  end

  def push(channel, event, data)
    Pusher.trigger(channel, event, data)
  end
end
