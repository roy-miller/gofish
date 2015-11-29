require 'spec_helper'

describe MatchClientNotifier do
  let(:match) { build(:match) }
  let(:notifier) { MatchClientNotifier.new(match) }

  it 'pushes notification to subscribers when match updates' do
    notifier.observe_match
    allow(notifier).to receive(:push)
    match.notify_observers
    expect(notifier).to have_received(:push).with("game_play_channel_#{match.id}", 'match_change_event')
  end
end
