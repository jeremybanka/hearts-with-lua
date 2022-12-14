local deck      = require "lib.deck"
local playerlib = require "lib.player"
local util      = require "lib.util"
local cards     = require "lib.cards"
local printer   = require "lib.printer"
local narration = require "lib.narration"
local egg       = require "lib.SECRET.SPOILER_ALERT.PROCEED_AT_YUOR_OWN_RISK.egg"

---@class gamelib : table A library of functions for a card game.
---@field deck string[]
---@field heartsBroken boolean
---@field leadingSuit? string
---@field trick table<string, string>
---@field players player[]
---@field turn integer
---@field round integer
---@field narrative NarrativeBeat[]
---@field narrativeMarker integer
local gamelib = {}

gamelib.deck = deck.shuffle(deck.create())
gamelib.heartsBroken = false
gamelib.leadingSuit = nil
gamelib.players = {}
gamelib.trick = {}
gamelib.turn = 1
gamelib.round = 1
gamelib.narrative = {}
gamelib.narrativeMarker = 0

---check whether the game has ended
---@param game gamelib
---@return boolean
function gamelib.isOver(game)
  if SECRET_FLAG_ROUXLS_RUINS_THE_GAME then
    return egg.rouxlsEndGame(game)
  end
  return util.every(game.players, function(player)
    return #player.hand == 0
  end) and #util.entries(game.trick) == 0
end

---end game and calculate final points
---@param game gamelib
---@return nil
function gamelib.endGame(game)
  if (util.some(game.players, function(player) return player.points == 26 end)) then
    for _, player in pairs(game.players) do
      if (player.points == 26) then
        player.points = 0
      else
        player.points = 26
      end
    end
  end
  local winner = util.reduce(game.players, function(acc, player)
    if (player.points < acc.points) then
      return player
    else
      return acc
    end
  end, game.players[1])
  game:narrate({ {
    description = "The game is over! " .. winner.name .. " wins!",
  }, {
    description = "Final scores:",
  } })
  for _, player in pairs(game.players) do
    print(player.name .. ": " .. player.points)
  end
  if (SECRET_FLAG_ROUXLS_RUINS_THE_GAME) then
    game:narrate({ {
      speaker = "Rouxls Kaard",
      description = "This is an impropriety! I hadst the most many of pointes!"
    } })
  end
  print("Thanks for playing!")
end

---heads up display
---@param game gamelib
---@return nil
function gamelib.printHud(game)
  os.execute('clear')
  local vessels = game:getVessels()
  ---you can debug the strategy of an npc by uncommenting the following line
  -- table.insert(vessels, game:getPlayer("Noelle"))
  ---you can visualize the upcoming narrative by uncommenting the following lines
  -- util.log(game.narrative)
  -- util.log(game.narrativeMarker)
  for _, vessel in ipairs(vessels) do
    local handContent = vessel:readHand()
    print("YOUR HAND (" .. vessel.name .. ")")
    printer.wrapping(handContent)
    print()
    print()
  end
  local playerStats = game:getAllPlayerStats()
  printer.tabular(playerStats, { cellSize = 16, orientation = 'horizontal' })
  print()
  print()
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
    game:dealCard(player)
  end
  return game
end

---deal out all cards evenly to the players, leaving extras in the deck
---@param game gamelib
---@return gamelib
function gamelib.dealAllCards(game)
  while #game.deck >= #game.players do
    game:dealOneToEachPlayer()
  end
  return game
end

---get player with the two of clubs
---@param game gamelib
---@return player?
function gamelib.getStartingPlayer(game)
  for _, player in ipairs(game.players) do
    if util.contains(player.hand, '2C') then
      return player
    end
  end
end

---start game
---@param game gamelib
---@return gamelib
function gamelib.startGame(game)
  game:dealAllCards()
  local you = game:getVessels()[1]
  table.insert(you.hand, 'RK') -- ????
  local startingPlayer = game:getStartingPlayer()
  game.turn = util.indexOf(game.players, startingPlayer)
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
---@return player
function gamelib.getPlayer(game, playerName)
  for _, player in ipairs(game.players) do
    if player.name == playerName then
      return player
    end
  end
  error("Player " .. playerName .. " not found.")
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
  local playerMustFollowSuit = util.some(
    player.hand,
    function(card)
      return cards.getSuit(card) == game.leadingSuit
    end
  )
  local playerHasOnlyHearts = not util.some(
    player.hand,
    function(card)
      return cards.getSuit(card) ~= 'H'
    end
  )
  local heartsMayBeBroken = playerHasOnlyHearts or game.round ~= 1

  for _, card in ipairs(player.hand) do
    local suit = cards.getSuit(card)

    if #trickEntries == 0 then
      if game.round == 1 then
        return { '2C' }
      end
      if suit ~= 'H' or game.heartsBroken or playerHasOnlyHearts then
        table.insert(playableCards, card)
      end
    else
      if playerMustFollowSuit then
        if suit == game.leadingSuit then
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
  local suit = cards.getSuit(card)
  if not game.heartsBroken and suit == 'H' then
    game.heartsBroken = true
  end
  if not game.leadingSuit then
    game.leadingSuit = suit
  end
  player:loseCard(card)
  game.trick[playerName] = card
  if (cards.name(card) == "LANCER") then
    egg.lancerPlayed(game)
  end
  if (cards.name(card) == "ROUXLS KAARD") then
    egg.rouxlsPlayed(game)
  end
  return game
end

---get card played this turn
---@param game gamelib
---@return string?
function gamelib.getCardPlayedThisTurn(game)
  local currentPlayer = game.players[game.turn]
  local lastPlayedCard = game.trick[currentPlayer.name]
  return lastPlayedCard
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
---@return player
function gamelib.getCurrentPlayer(game)
  local currentPlayer = game.players[game.turn]
  if not currentPlayer then
    error("No current player.")
  end
  return currentPlayer
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
---@return player, string
function gamelib.getTrickTaker(game)
  local trickEntries = util.entries(game.trick)
  local takersName = trickEntries[1].key
  local takersCard = trickEntries[1].val
  for _, entry in ipairs(trickEntries) do
    local card = entry.val
    local suit = cards.getSuit(card)
    if suit == game.leadingSuit then
      local numRank = cards.getNumericRank(card)
      local numRankW = cards.getNumericRank(takersCard)
      if numRank > numRankW then
        takersName = entry.key
        takersCard = card
      end
    end
  end
  local taker = game:getPlayer(takersName)
  return taker, takersCard
end

---check if a card may win the trick
---@param game gamelib
---@param card string
---@return "yes"|"no"|"maybe"
function gamelib.mayWinTrick(game, card)
  local trickEntries = util.entries(game.trick)
  if #trickEntries == 0 then
    return "maybe"
  end
  local suit = cards.getSuit(card)
  if suit ~= game.leadingSuit then
    return "no"
  end
  local _, currentLeadingCard = game:getTrickTaker()
  local numRank = cards.getNumericRank(card)
  local numRankW = cards.getNumericRank(currentLeadingCard)
  if numRank < numRankW then
    return "no"
  end
  if #trickEntries == #game.players - 1 then
    return "yes"
  end
  return "maybe"
end

---hearts: get points for trick
---@param game gamelib
---@return integer
function gamelib.getTrickPoints(game)
  local points = 0
  for _, card in pairs(game.trick) do
    points = points + cards.getPoints(card)
  end
  return points
end

---end round
---@param game gamelib
---@return gamelib
function gamelib.endRound(game)
  if SECRET_FLAG_ROUXLS_RUINS_THE_GAME then
    egg.rouxlsScores(game)
  else
    local trickTaker = game:getTrickTaker()
    if trickTaker then
      table.insert(trickTaker.tricksTaken, game.trick)
      trickTaker.points = trickTaker.points + game:getTrickPoints()
    end
    game.turn = util.indexOf(game.players, trickTaker)
  end
  game.round = game.round + 1
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
  if playerIsCurrent then
    markers = markers .. "*"
  end
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
  table.insert(summary, "points: " .. player.points)
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

---ingest narrative
---@param game gamelib
---@param narrative NarrativeBeat[]
---@return gamelib
function gamelib.narrate(game, narrative)
  game.narrative = narrative
  narration.narrate(game, narrative)
  game.narrative = {}
  game.narrativeMarker = 0
  return game
end

---interrupt narrative
---@param game gamelib
---@param digression NarrativeBeat[]
---@param when? integer
---@return gamelib
function gamelib.interruptNarrative(game, digression, when)
  local marker = game.narrativeMarker + (when or 1)
  -- uncomment to debug interruptions
  -- print("interrupting narrative at marker " .. marker)
  for _, beat in ipairs(digression) do
    table.insert(game.narrative, marker, beat)
    marker = marker + 1
  end

  return game
end

return gamelib
