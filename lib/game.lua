local deck      = require "lib.deck"
local playerlib = require "lib.player"
local util      = require "lib.util"

---@class gamelib : table A library of functions for a card game.
---@field deck string[]
---@field heartsBroken boolean
---@field trick table<string, string>
---@field players player[]
---@field turn integer
---@field round integer
--
local gamelib = {}

gamelib.deck = deck.shuffle(deck.create())
gamelib.heartsBroken = false
gamelib.players = {}
gamelib.trick = {}
gamelib.turn = 1

---check whether the game has ended
---@param game gamelib
---@return boolean
function gamelib.isOver(game)
  return util.every(game.players, function(player)
    return #player.hand == 0
  end)
end

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

  local trickEntries = util.entries(game.trick)

  local leadingSuit = #trickEntries > 0 and trickEntries[1].val:sub(-1) or nil
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

    if #trickEntries == 0 then

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

---get player with the two of clubs
---@param game gamelib
---@return player?
function gamelib.getVessel(game)
  for _, player in ipairs(game.players) do
    if util.contains(player.hand, '2C') then
      return player
    end
  end
end

---get characters who are controlled by the player
---@param game gamelib
---@return player[]
function gamelib.getVessels(game)
  local vessels = {}
  for _, player in ipairs(game.players) do
    if player.isVessel then
      table.insert(vessels, player)
    end
  end
  return vessels
end

---get the player whose turn it is
---@param game gamelib
---@return player?
function gamelib.getCurrentPlayer(game)
  return game.players[game.turn]
end

---get summary array for a player
---@param game gamelib
---@param player player
---@return string[]
function gamelib.getPlayerStats(game, player)
  local summary = {}
  local playerIsCurrent = game:getCurrentPlayer() == player
  local markers = ""
  ---if it's the player's turn, mark it
  if playerIsCurrent then
    markers = markers .. "* "
  end
  ---if the player is a vessel, mark it
  if player.isVessel then
    markers = markers .. "(you)"
  end
  local trickFallback = ""
  if (playerIsCurrent) then
    trickFallback = "..."
  end
  table.insert(summary, markers)
  table.insert(summary, player.name)
  table.insert(summary, game.trick[player.name] or trickFallback)
  table.insert(summary, "tricks: " .. #player.tricksTaken)
  for _, trick in ipairs(player.tricksTaken) do
    table.insert(summary, table.concat(trick, ", "))
  end
  return summary
end

---get array of player summary arrays
---@param game gamelib
---@return string[][]
function gamelib.getAllPlayerStats(game)
  local function statsOf(player)
    return game:getPlayerStats(player)
  end

  local stats = util.map(game.players, statsOf)
  return stats
end

return gamelib
