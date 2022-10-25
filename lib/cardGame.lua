local deck = require "lib.deck"

-- create game state
local function initGame()
  return {
    deck = deck.shuffle(deck.create()),
    heartsBroken = false,
    players = {},
    trick = {},
    turn = 1
  }
end

-- deal a card to a player
local function dealCard(game, player)
  local card = table.remove(game.deck)
  table.insert(player.hand, card)
end

-- deal a card to each player
local function dealOneToPlayers(game)
  for _, player in ipairs(game.players) do
    dealCard(game, player)
  end
end

-- deal out all the cards
local function dealAllCards(game)
  while #game.deck >= #game.players do
    dealOneToPlayers(game)
  end
end

return {
  init = initGame,
  dealAllCards = dealAllCards
}
