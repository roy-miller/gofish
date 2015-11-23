require 'spec_helper'

describe MatchClientNotifier do
  let(:match) { build(:match) }
  let(:notifier) { MatchClientNotifier.new(match) }

  it 'pushes notification to subscribers when match updates' do
    allow(notifier).to receive(:push)
    expect(notifier).to receive(:push).with("game_play_channel_#{match.id}", 'match_change_event')
    match.changed
    match.notify_observers
  end
end