var PlayerView = function PlayerView(matchId, playerId) {
  this.matchId = matchId;
  this.playerId = playerId;
  this.playerUrl = "http://localhost:4567/matches/" + this.matchId + "/users/" + this.playerId
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
      //console.dir(matchPerspective);
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
  var self = this;
  //updatePlayerInfo
  //updatePlayerCards
  //updateDeck
  //updateOpponents
  $('#your_hand_card_count').text(matchPerspective.cards.length);
  $('#your_hand_book_count').text(matchPerspective.book_count);

  $('#your_hand_cards').empty();
  matchPerspective.cards.forEach(function (card) {
    card_div = document.createElement('div');
    card_div.className = 'your-card ' + card.suit.toLowerCase() + card.rank.toLowerCase();
    card_link = document.createElement('a');
    card_link.onclick = function() { self.setSelectedCardRank(card.rank); };
    card_image = document.createElement('img');
    card_image.src = '/images/' + card.suit.toLowerCase() + card.rank.toLowerCase() + '.png';
    card_link.appendChild(card_image);
    card_div.appendChild(card_link);
    $('#your_hand_cards').append(card_div);
  });

  $('#fish_pond_card_count').text(matchPerspective.deck_card_count);

  matchPerspective.opponents.forEach(function (opponent, index) {
    $('#opponent_' + index + '_hand_card_count').text(opponent.card_count);
    $('#opponent_' + index + '_hand_book_count').text(opponent.book_count);
    opponent_card_images = [];
    for (var i=0; i < opponent.card_count; i++) {
      opponent_card_images.push("<div class='opponent-card facedown'><img src='/images/backs_blue.png'/></div>")
    }
  });
}
