require 'spec_helper'

describe(Player) do
  it 'creates a player with cards given' do
    cards = ['2D', '3C', 'AS', 'JH', '10S']
    player = Player.with_name_and_cards('playername', cards)
    expect(player.has_cards_with_rank_and_suit(cards)).to be true
  end

  let(:player) { Player.new }

  it 'creates a player with a name and no hand' do
    expect(player.name).to eq 'default'
    expect(player.hand).to be_empty
  end

  it 'responds that player is out of cardsplayer has no cards' do
    expect(player.out_of_cards?).to be true
  end

  context 'with hand' do
    let(:twos_card1) { Card.new(rank: '2', suit: 'D') }
    let(:twos_card2) { Card.new(rank: '2', suit: 'S') }
    let(:twos_card3) { Card.new(rank: '2', suit: 'C') }
    let(:sixes_card1) { Card.new(rank: '6', suit: 'D') }
    let(:twos) { Book.new }
    let(:sixes) { Book.new }

    context 'containing one book' do
      before do
        twos.add_card(twos_card1)
        twos.add_card(twos_card2)
        twos.add_card(twos_card3)
        player.hand << twos
      end

      it 'adds card to new book if book corresponding to card does not exist' do
        card = Card.new(rank: 'Q', suit: 'H')
        player.add_card_to_hand(card)
        expect(player.hand.last.cards).to include card
      end

      it 'collects a book when added card completes a book' do
        card = Card.new(rank: '2', suit: 'H')
        player.add_card_to_hand(card)
        expect(player.full_books.count).to eq 1
      end

      it 'responds that player is not out of cards when player has cards' do
        expect(player.out_of_cards?).to be false
      end
    end

    context 'containing two books' do
      before do
        twos.add_card(twos_card1)
        twos.add_card(twos_card2)
        twos.add_card(twos_card3)
        player.hand << twos
        sixes.add_card(sixes_card1)
        player.hand << sixes
      end

      it 'answers the count of cards in all of its books' do
        expect(player.card_count).to eq 4
      end

      it 'gives all cards in all books when asked' do
        expect(player.cards).to match_array [twos_card1, twos_card2, twos_card3, sixes_card1]
      end

      context 'with request' do
        let(:originator) { User.new(name: 'player1') }
        let(:recipient) { User.new(name: 'player2') }
        let(:request) { Request.new(originator: originator, recipient: recipient, card_rank: nil) }

        it 'receives requests for cards, returns no cards if has none of requested rank' do
          request.card_rank = 'A'
          response = player.receive_request(request)
          expect(response).not_to be_nil
          expect(response.cards_returned?).to be false
        end

        it 'receives requests for cards, returns cards if has any of requested rank' do
          request.card_rank = '2'
          response = player.receive_request(request)
          expect(response).not_to be_nil
          expect(response.cards_returned?).to be true
          expect(response.cards_returned).to match_array [twos_card1, twos_card2, twos_card3]
          expect(player.cards).to include(sixes_card1)
          expect(player.cards).not_to include(twos_card1, twos_card2, twos_card3)
        end

        it 'removes empty books after returning cards for request if that empties books' do
          request.card_rank = '6'
          response = player.receive_request(request)
          expect(player.cards).to include(twos_card1, twos_card2, twos_card3)
          expect(player.cards).not_to include(sixes_card1)
          expect(player.hand).to include(twos)
          expect(player.hand).not_to include(sixes)
        end

        context 'with response containing card in existing book in hand, not full after' do
          before do
            request.cards_returned = [Card.new(rank: '6', suit: 'S')]
          end

          it 'adds cards returned to existing book' do
            player.receive_response(request)
            expect(player.hand.count).to eq 2
            expected_cards_in_existing_book = [sixes_card1, request.cards_returned.first]
            expect(player.hand.last.cards).to match_array expected_cards_in_existing_book
          end
        end

        context 'with response containing card in existing book in hand, full after' do
          before do
            request.cards_returned = [Card.new(rank: '2', suit: 'H')]
          end

          it 'adds cards returned to existing book, moves to full books' do
            player.receive_response(request)
            expected_cards_in_full_book = [twos_card1, twos_card2, twos_card3, request.cards_returned.first]
            expect(player.hand.count).to eq 1
            expect(player.full_books.count).to eq 1
            expect(player.full_books.first.cards).to match_array expected_cards_in_full_book
          end
        end
      end

    end
  end
end
