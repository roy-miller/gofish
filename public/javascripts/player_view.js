var PlayerView = function PlayerView(matchId, playerId) {
  this.matchId = matchId;
  this.playerId = playerId;
  this.playerUrl = "http://localhost:4567/matches/" + this.matchId + "/users/" + this.playerId
  this.matchPerspective = null;
  this.listenForRankSelection();
  this.listenForCardRequests();
}

PlayerView.prototype.listenForRankSelection = function() {
  var self = this;
  playerCardLinkElements = document.getElementsByClassName('your-card');
  Array.prototype.forEach.call(playerCardLinkElements, function(element) {
    element.onclick = function() {
      self.setSelectedCardRank(this.getAttribute('data-rank'));
    };
  }.bind(this));
}

PlayerView.prototype.listenForCardRequests = function() {
  var self = this;
  opponentNameElements = document.getElementsByClassName('opponent-name');
  Array.prototype.forEach.call(opponentNameElements, function(element) {
    element.onclick = function() {
      var opponentId = this.getAttribute('data-opponent-id');
      var selectedCardRank = self.getSelectedCardRank();
      if (document.getElementById('selected_card_rank').value) {
        $.post('/request_card', {
          match_id: self.matchId,
          requestor_id: self.playerId,
          requested_id: opponentId,
          rank: selectedCardRank
        }).success(function()  {
          console.log("asked for card -> matchId: " + self.matchId +
                      ", requestorId: " + self.playerId +
                      ", requestedId:" + opponentId +
                      ", rank: " + selectedCardRank);
        });
      }
    };
  }.bind(this));
}

PlayerView.prototype.selectedCardRankElement = function () {
  element = document.getElementById('selected_card_rank');
  return element;
}

PlayerView.prototype.setSelectedCardRank = function(value) {
  this.selectedCardRankElement().value = value;
  console.log('set selected rank: ' +  value);
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
    },
    error: function(result) {
      console.log("error getting match state\n" + result);
    }
  });
}

PlayerView.prototype.updateMatchIfStarted = function (matchPerspective) {
  if (matchPerspective.status == 'started') { this.updateMatch(matchPerspective); }
}

PlayerView.prototype.start = function() {
  window.location = this.playerUrl;
}

PlayerView.prototype.setMessages = function(messages) {
  newMessages = []
  messages.forEach(function (message) { newMessages.push(message); });
  document.getElementById('messages').innerHTML = newMessages.join("\n");
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
  return document.getElementById('your_hand_cards')
}

PlayerView.prototype.updatePlayerCards = function() {
  playerHandElement().innerHTML = '';
  this.matchPerspective.cards.forEach(function (card) {
    card_div = document.createElement('div');
    card_div.className = 'your-card ' + card.suit.toLowerCase() + card.rank.toLowerCase();
    card_link = document.createElement('a');
    card_link.onclick = function() { self.setSelectedCardRank(card.rank); };
    card_image = document.createElement('img');
    card_image.src = '/images/' + card.suit.toLowerCase() + card.rank.toLowerCase() + '.png';
    card_link.appendChild(card_image);
    card_div.appendChild(card_link);
    playerHandElement.appendChild(card_div);
  });
}

PlayerView.prototype.updateDeck = function() {
  document.getElementById('fish_pond_card_count').textContent = this.matchPerspective.deck_card_count;
}

PlayerView.prototype.opponentHandElement = function(opponentNumber) {
  return document.querySelector('#opponent_' + opponentNumber + '_hand .opponent-hand-cards')
}

PlayerView.prototype.updateOpponents = function() {
  this.matchPerspective.opponents.forEach(function (opponent, index) {
    document.getElementById('opponent_' + index + '_hand_card_count').textContent = opponent.card_count;
    document.getElementById('opponent_' + index + '_hand_book_count').textContent = opponent.book_count;
    opponentHandElement(index).innerHTML = '';
    for (var i=0; i < opponent.card_count; i++) {
      new_card = document.createElement('div');
      new_card.className = 'opponent-card';
      card_image = document.createElement('img');
      card_image.src = '/images/backs_blue.png';
      new_card.appendChild(card_image);
      opponentHandElement(index).appendChild(new_card);
    }
  });
}
