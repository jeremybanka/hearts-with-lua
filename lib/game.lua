local deck      = require "lib.deck"
local playerlib = require "lib.player"
local util      = require "lib.util"
local cards     = require "lib.cards"

---@class gamelib : table A library of functions for a card game.
---@field deck string[]
---@field heartsBroken boolean
---@field leadingSuit? string
---@field trick table<string, string>
---@field players player[]
---@field turn integer
---@field round integer
local gamelib = {}

gamelib.deck = deck.shuffle(deck.create())
gamelib.heartsBroken = false
gamelib.leadingSuit = nil
gamelib.players = {}
gamelib.trick = {}
gamelib.turn = 1
gamelib.round = 1

---check whether the game has ended
---@param game gamelib
---@return boolean
function gamelib.isOver(game)
  return util.every(game.players, function(player)
    return #player.hand == 0 and #util.entries(game.trick) == 0
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
---@return string[]
function gamelib.getPlayableCards(game, playerName)
  local player = game:getPlayer(playerName)
  if not player then
    return {}
  end
  local playableCards = {}

  local trickEntries = util.entries(game.trick)
  -- util.log(trickEntries )
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
  local heartsMayBeBroken = playerHasOnlyHearts or game.round ~= 1
  -- print('heartsMayBeBroken', heartsMayBeBroken)
  -- print('playerMustFollowSuit', playerMustFollowSuit)
  -- print('leadingSuit', leadingSuit)

  for _, card in ipairs(player.hand) do
    local suit = card:sub(-1)

    if #trickEntries == 0 then
      -- print("#trickEntries", #trickEntries)
      -- print("suit ~= 'H'", suit ~= 'H')
      -- print("game.heartsBroken", game.heartsBroken)
      -- print("playerHasOnlyHearts", playerHasOnlyHearts)
      if suit ~= 'H' or game.heartsBroken or playerHasOnlyHearts then
        table.insert(playableCards, card)
      end
    else
      if playerMustFollowSuit then
        if suit == leadingSuit then
          table.insert(playableCards, card)
        end
      elseif suit ~= 'H' or heartsMayBeBroken then
        table.insert(playableCards, card)
      end
    end
  end
  return playableCards
end

---play a card
---@param game gamelib
---@param playerName string
---@param card string
---@return gamelib
function gamelib.playCard(game, playerName, card)
  local player = game:getPlayer(playerName)
  if not player then
    return game
  end
  local playableCards = game:getPlayableCards(playerName)
  if not util.contains(playableCards, card) then
    return game
  end
  local suit = card:sub(-1)
  if not game.heartsBroken and suit == 'H' then
    game.heartsBroken = true
  end
  if not game.leadingSuit then
    game.leadingSuit = suit
  end
  player:loseCard(card)
  game.trick[playerName] = card
  return game
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

---pass turn to a player
---@param game gamelib
---@param playerName string
---@return gamelib
function gamelib.passTurnTo(game, playerName)
  local player = game:getPlayer(playerName)
  if player then
    game.turn = util.indexOf(game.players, player)
  end
  return game
end

---pass turn to the next player
---@param game gamelib
---@return gamelib
function gamelib.passTurnToNextPlayer(game)
  local next = game.turn + 1
  if next > #game.players then
    next = 1
  end
  game.turn = next
  return game
end

---check who won the trick
---@param game gamelib
---@return player?
function gamelib.getTrickWinner(game)
  local trickEntries = util.entries(game.trick)
  local leadingSuit = trickEntries[1].val:sub(-1)
  local winner = trickEntries[1].key
  local winnerCard = trickEntries[1].val
  for _, entry in ipairs(trickEntries) do
    local card = entry.val
    local suit = card:sub(-1)
    if suit == leadingSuit then
      local numRank = cards.getNumericRank(card)
      local numRankW = cards.getNumericRank(winnerCard)
      if numRank > numRankW then
        winner = entry.key
        winnerCard = card
      end
    end
  end
  return game:getPlayer(winner)
end

---hearts: get score of trick
---@param game gamelib
---@return number
function gamelib.getTrickScore(game)
  local score = 0
  for _, card in pairs(game.trick) do
    score = score + cards.getScore(card)
  end
  return score
end

---end round
---@param game gamelib
---@return gamelib
function gamelib.endRound(game)
  local trickWinner = gamelib.getTrickWinner(game)
  if trickWinner then
    table.insert(trickWinner.tricksTaken, game.trick)
    trickWinner.score = trickWinner.score + game:getTrickScore()
  end
  game.round = game.round + 1
  game.turn = util.indexOf(game.players, trickWinner)
  game.trick = {}
  game.leadingSuit = nil
  return game
end

---end turn
---@param game gamelib
---@return gamelib
function gamelib.endTurn(game)
  if #util.entries(game.trick) == #game.players then
    game:endRound()
  else
    game:passTurnToNextPlayer()
  end
  return game
end

---is it your turn?
---@param game gamelib
---@return boolean
function gamelib.isYourTurn(game)
  return game:getCurrentPlayer().isVessel
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
    markers = markers .. "*"
  end
  ---if the player is a vessel, mark it
  -- if player.isVessel then
  --   markers = markers .. "(you)"
  -- end
  local trickCard = nil
  local trickFallback = ""
  if (playerIsCurrent) then
    trickFallback = "..."
  end
  if game.trick[player.name] then
    trickCard = cards.name(game.trick[player.name])
  else
    trickCard = trickFallback
  end

  table.insert(summary, markers)
  table.insert(summary, player.name)
  table.insert(summary, trickCard)
  table.insert(summary, "tricks: " .. #player.tricksTaken)
  table.insert(summary, "score: " .. player.score)
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
