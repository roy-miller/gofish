# gofish
GoFish card game
<!--    <div id='card_table'>
      <div id="your_hand">
        <% for @card in @player_hand %>
          <div class="your-card">
            <%= @card %>
          </div>
        <% end %>
      </div>
      <div id="oppenent_hands">
        <% for @opponent in @opponents%>
          <div class="oppenent_hand">
            <% for @card in @opponent_hand %>
              <div class="opponent-card">
                <img src="<%= @card.suit %><%= @card.rank %>.png" />
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
      <div id="fish_pond">
        <img/><div><%= @deck.count %></div>
      </div>
      <div id='messages'><%= @message %></div>
    </div>
  -->



  <div id="opponent_hands">
    <% for @opponent in @opponents%>
      <div class="opponent_hand">
        <% for @card in @opponent_hand %>
          <div class="opponent-card">
            <img src="<%= @card.suit %><%= @card.rank %>.png" />
          </div>
        <% end %>
      </div>
    <% end %>
  </div>
  <div id="fish_pond">
    <img/><div><%= @deck_card_count %></div>
  </div>
  <div id='messages'><%= @message %></div>
