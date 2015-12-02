var PlayerView = function PlayerView(matchId, playerId, logging) {
  this.matchId = matchId;
  this.playerId = playerId;
  this.playerUrl = "http://localhost:4567/matches/" + this.matchId + "/users/" + this.playerId;
  if(logging) {
    Pusher.log = function(message) {
     if (window.console && window.console.log) {
       window.console.log(message);
     }
    };
  };
  this.matchPerspective = null;
  this.listenForRankSelection();
  this.listenForCardRequests();
}

PlayerView.prototype.listenForRankSelection = function() {
  var self = this;
  var playerCardLinkElements = Array.prototype.slice.call(document.getElementsByClassName('your-card'));
  playerCardLinkElements.forEach(function(element) {
    element.onclick = function() {
      self.setSelectedCardRank(this.getAttribute('data-rank'));
    };
  }.bind(this));
}

PlayerView.prototype.listenForCardRequests = function() {
  var self = this;
  var opponentNameElements = Array.prototype.slice.call(document.getElementsByClassName('opponent-name'));
  opponentNameElements.forEach(function(element) {
    element.onclick = function() {
      var opponentId = this.getAttribute('data-opponent-id');
      var selectedCardRank = self.getSelectedCardRank();
      if (document.getElementById('selected_card_rank').value) {
        $.post('/request_card', {
          match_id: self.matchId,
          requestor_id: self.playerId,
          requested_id: opponentId,
          rank: selectedCardRank
        });
      }
    };
  }.bind(this));
}

PlayerView.prototype.selectedCardRankElement = function () {
  return document.getElementById('selected_card_rank');
}

PlayerView.prototype.setSelectedCardRank = function(value) {
  this.selectedCardRankElement().value = value;
};

PlayerView.prototype.getSelectedCardRank = function() {
  return this.selectedCardRankElement().value;
}

PlayerView.prototype.refresh = function() {
  var self = this;
  $.ajax({
    url: this.playerUrl + ".json",
    type: 'GET',
    dataType: 'json',
    success: function(matchPerspective) {
      self.setMessages(matchPerspective.messages);
      self.updateMatchIfStarted(matchPerspective);
    }
  });
}

// don't need this anymore?
PlayerView.prototype.updateMatchIfStarted = function (matchPerspective) {
  if (matchPerspective.status == 'started') { this.updateMatch(matchPerspective); }
}

PlayerView.prototype.setMessages = function(messages) {
  document.getElementById('messages').innerHTML = messages.join("\n");
}

PlayerView.prototype.updateMatch = function(matchPerspective) {
  this.matchPerspective = matchPerspective;
  this.updatePlayerInfo();
  this.updatePlayerCards();
  this.updateDeck();
  this.updateOpponents();
}

PlayerView.prototype.updatePlayerInfo = function() {
  document.getElementById('your_hand_card_count').textContent = this.matchPerspective.cards.length;
  document.getElementById('your_hand_book_count').textContent = this.matchPerspective.book_count;
}

PlayerView.prototype.playerHandElement = function() {
  return document.getElementById('your_hand_cards');
}

PlayerView.prototype.updatePlayerCards = function() {
  var self = this;
  this.playerHandElement().innerHTML = '';
  this.matchPerspective.cards.forEach(function (card) {
    var card_element = document.createElement('a');
    card_element.className = 'your-card';
    card_element.setAttribute('data-rank', card.rank);
    card_element.setAttribute('data-suit', card.suit);
    card_element.onclick = function() { self.setSelectedCardRank(card.rank); };
    var card_image = document.createElement('img');
    card_image.src = '/images/' + card.suit.toLowerCase() + card.rank.toLowerCase() + '.png';
    card_element.appendChild(card_image);
    self.playerHandElement().appendChild(card_element);
  });
}

PlayerView.prototype.updateOpponents = function() {
  var self = this;
  this.matchPerspective.opponents.forEach(function (opponent, index) {
    document.getElementById('opponent_' + index + '_hand_card_count').textContent = opponent.card_count;
    document.getElementById('opponent_' + index + '_hand_book_count').textContent = opponent.book_count;
    self.opponentHandElement(index).innerHTML = '';
    for (var i=0; i < opponent.card_count; i++) {
      var card_element = document.createElement('div');
      card_element.className = 'opponent-card';
      var card_image = document.createElement('img');
      card_image.src = '/images/backs_blue.png';
      card_element.appendChild(card_image);
      self.opponentHandElement(index).appendChild(card_element);
    }
  });
}

PlayerView.prototype.updateDeck = function() {
  document.getElementById('fish_pond_card_count').textContent = this.matchPerspective.deck_card_count;
}

PlayerView.prototype.opponentHandElement = function(opponentNumber) {
  return document.querySelector(".opponent[data-opponent-number='" + opponentNumber + "'] .opponent-hand-cards");
}
