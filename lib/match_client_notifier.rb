require 'pusher'

class MatchClientNotifier
  attr_reader :match

  def observe_match(match)
    @match = match
    match.add_observer(self)
  end

  def update(*args)
    push("game_play_channel_#{match.id}", 'match_change_event')
  end

  def push(channel, event)
    Pusher.trigger(channel, event, { message: "reload page" } )
  end
end
