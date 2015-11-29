require_relative './match'
require_relative './user'

class RobotUser < User
  #attr_reader :id, :match
  #has_and_belongs_to_many :matches
  attr_accessor :think_time

  def initialize(think_time = 0)
    @think_time = think_time
  end

  def add_match(match)
    self.match = match
    self.match.add_observer(self)
  end

  # def id
  #   self.object_id
  # end

  # def name
  #   'robot' + self.id.to_s
  # end

  def update(*args)
    make_request if (self.match.current_player == self)
  end

  def make_request
    contemplate_before {
      self.match.ask_for_cards(requestor: self, recipient: pick_opponent, card_rank: pick_rank)
    }
  end

  def player
    self.match.player_for(self)
  end

  protected

  def opponents
    self.match.opponents_for(self)
  end

  def pick_opponent
    opponents.sample
  end

  def pick_rank
    player.hand.sample.rank
  end

  def contemplate_before
    if self.think_time > 0
      Thread.start do
        sleep(self.think_time)
        yield
      end
    else
      yield
    end
  end
end
