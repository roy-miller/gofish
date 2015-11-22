class RobotUser
  attr_reader :match, :think_time

  def initialize(think_time = 0)
    @think_time = think_time
  end

  def add_match(match)
    @match = match
    match.add_observer(self)
  end

  def name
    'robot'
  end

  def update(event)
    if event == 'changed'
      make_request if (match.current_user == self)
    end
  end

  def make_request
    contemplate_before {
      match.ask_for_cards(requestor: self, recipient: pick_opponent, card_rank: pick_rank)
    }
  end

  def player
    match.player_for(self)
  end

  protected

  def opponents
    match.opponents_for(self)
  end

  def pick_opponent
    opponents.sample
  end

  def pick_rank
    player.hand.sample.rank
  end

  def contemplate_before
    if think_time > 0
      Thread.start do
        sleep(think_time)
        yield
      end
    else
      yield
    end
  end
end
