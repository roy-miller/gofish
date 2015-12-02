require 'pusher'
require 'timeout'

class MatchMaker
  attr_accessor :start_timeout_seconds, :pending_users

  def initialize
    @start_timeout_seconds = 5
  end

  def match(user, number_of_players)
    relevant_pending_users = pending_users[number_of_players]
    trigger_start_timer(number_of_players) if relevant_pending_users.empty?
    relevant_pending_users << user
    start_match_with(relevant_pending_users.shift(number_of_players)) if enough_users_for(number_of_players)
  end

  def pending_users
    @pending_users ||= Hash.new { |hash, key| hash[key] = [] }
  end

  private

  def enough_users_for(number_of_players)
    pending_users[number_of_players].count >= number_of_players
  end

  def start_match_with(users)
    match = Match.create(users: users) # TODO need match.id (save #1)
    match.start
    MatchClientNotifier.new.observe_match(match)
    match.save! # TODO AND have to save observers for robot match (save #2)
    match
  end

  def trigger_start_timer(number_of_players, timeout_seconds=start_timeout_seconds)
    Thread.start {
      begin
        Timeout::timeout(timeout_seconds) {
          until enough_users_for(number_of_players)
            # better way to wait?
          end
        }
      rescue Timeout::Error => e
        add_robots(number_of_players)
      end
    }
  end

  def add_robots(number_of_players)
    a_match = nil
    until a_match do
      robot = RobotUser.create
      robot.update_column(:name, "robot#{robot.id}")
      #robot.name = "robot#{robot.id}"
      #robot.update(name: "robot#{robot.id}")
      #robot.update_attributes(:name, "robot#{robot.id}")
      #robot.write_attribute(:name, "robot#{robot.id}"); robot.save
      a_match = match(robot, number_of_players)
      robot.observe_match(a_match)
      a_match.save!
    end
    a_match.users.each { |user| Pusher.trigger("wait_channel_#{user.id}", 'match_start_event', { message: "/matches/#{a_match.id}/users/#{user.id}" }) }
  end
end
