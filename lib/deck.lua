local cards = require "lib.cards"

-- create a deck of cards
local function createDeck()
  local deck = {}
  for _, suit in ipairs(cards.SUITS) do
    for _, rank in ipairs(cards.RANKS) do
      table.insert(deck, rank .. suit)
    end
  end
  return deck
end

-- shuffle a deck of cards
local function shuffleDeck(deck)
  local cards = #deck
  while cards > 1 do
    local rand = math.random(cards)
    deck[cards], deck[rand] = deck[rand], deck[cards]
    cards = cards - 1
  end
  return deck
end

return {
  create = createDeck,
  shuffle = shuffleDeck
}
