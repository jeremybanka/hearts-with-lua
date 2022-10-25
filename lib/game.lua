local deck      = require "lib.deck"
local playerlib = require "lib.player"
local util      = require "lib.util"

---@class gamelib : table A library of functions for a card game.
---@field deck string[]
---@field heartsBroken boolean
---@field trick string[]
---@field players player[]
---@field turn integer
local gamelib = {}

gamelib.deck = deck.shuffle(deck.create())
gamelib.heartsBroken = false
gamelib.players = {}
gamelib.trick = {}
gamelib.turn = 1

---deal a card to a player
---@param game gamelib
---@param player player
function gamelib.dealCard(game, player)
  local card = table.remove(game.deck)
  table.insert(player.hand, card)
  return game
end

---deal a card to each player
---@param game gamelib
---@return gamelib
function gamelib.dealOneToEachPlayer(game)
  for _, player in ipairs(game.players) do
    gamelib.dealCard(game, player)
  end
  return game
end

---deal out cards evenly to the players, leaving extras in the deck
---@param game gamelib
---@return gamelib
function gamelib.dealAllCards(game)
  while #game.deck >= #game.players do
    gamelib.dealOneToEachPlayer(game)
  end
  return game
end

---add a player to the game
---@param game gamelib
---@param playerName string
---@return gamelib
function gamelib.addPlayer(game, playerName)
  local player = playerlib.new(playerName)
  table.insert(game.players, player)
  return game
end

---get a player in the game
---@param game gamelib
---@param playerName string
---@return player?
function gamelib.getPlayer(game, playerName)
  for _, player in ipairs(game.players) do
    if player.name == playerName then
      return player
    end
  end
end

---play as a player
---@param game gamelib
---@param playerName string
---@return gamelib
function gamelib.playAs(game, playerName)
  local player = game:getPlayer(playerName)
  if player then
    player.isVessel = true
  end
  return game
end

---get playable cards for a player
---@param game gamelib
---@param playerName string
---@return table<string, string>
function gamelib.getPlayableCards(game, playerName)
  local player = game:getPlayer(playerName)
  if not player then
    return {}
  end
  local playableCards = {}

  local leadingSuit = #game.trick > 0 and game.trick[1]:sub(-1) or nil
  local playerMustFollowSuit = util.some(
    player.hand,
    function(card)
      return card:sub(-1) == leadingSuit
    end
  )
  local playerHasOnlyHearts = not util.some(
    player.hand,
    function(card)
      return card:sub(-1) ~= 'H'
    end
  )
  local heartsMayBeBroken = playerHasOnlyHearts or game.turn ~= 1

  for _, card in ipairs(player.hand) do
    local suit = card:sub(-1)

    if #game.trick == 0 then

      -- print("suit ~= 'H'", suit ~= 'H')
      -- print("game.heartsBroken", game.heartsBroken)
      -- print("playerHasOnlyHearts", playerHasOnlyHearts)
      if suit ~= 'H' or game.heartsBroken or playerHasOnlyHearts then
        table.insert(playableCards, card)
      end
    else
      if playerMustFollowSuit and suit == leadingSuit then
        table.insert(playableCards, card)
      elseif suit ~= 'H' or heartsMayBeBroken then
        table.insert(playableCards, card)
      end
    end
  end
  return playableCards
end

return gamelib
