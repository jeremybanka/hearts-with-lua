local deck = require "lib.deck"
---@meta
---
---@class gamelib
---A library of functions for a card game.
---@field deck table
---@field heartsBroken boolean
---@field trick table
---@field players table
local gamelib = {}

gamelib.deck = deck.shuffle(deck.create())
gamelib.heartsBroken = false
gamelib.players = {}
gamelib.trick = {}
gamelib.turn = 1

-- create game state
-- function gamelib.init()
--   return {
--     deck = deck.shuffle(deck.create()),
--     heartsBroken = false,
--     players = {},
--     trick = {},
--     turn = 1
--   }
-- end

-- deal a card to a player
function gamelib.dealCard(game, player)
  local card = table.remove(game.deck)
  table.insert(player.hand, card)
end

-- deal a card to each player
function gamelib.dealOneToEachPlayer(game)
  for _, player in ipairs(game.players) do
    gamelib.dealCard(game, player)
  end
end

-- deal out all the cards
function gamelib.dealAllCards(game)
  while #game.deck >= #game.players do
    gamelib.dealOneToEachPlayer(game)
  end
end

function gamelib.addPlayer(game, playerName)
  local player = {
    name = playerName,
    hand = {},
    tricksTaken = {},
    score = 0,
    isVessel = false
  }
  table.insert(game.players, player)
  return game
end

return gamelib
