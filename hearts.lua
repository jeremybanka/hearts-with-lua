local newGame   = require "lib.game"
local cards     = require "lib.cards"
local util      = require "lib.util"
local printer   = require "lib.printer"
local narration = require "lib.narration"
local strategy  = require "lib.SECRET.strategy"

---prompt the player to play a card
---@param game gamelib
---@return nil
local function playCardPlease(game)
  local player = game:getCurrentPlayer()
  local playableCards = game:getPlayableCards(player.name)
  local playableCardNames = util.map(playableCards, cards.name)
  printer.list(playableCardNames, { indentFirstLine = 2, })
  print("(Press the number of the card you wish to play, then press RETURN ⏎)")
  io.write("> ")
  local cardIdx = io.read('*n')
  local chosenCard = playableCards[cardIdx] or playableCards[1]
  game:playCard(player.name, chosenCard)
  _ = io.read() -- for some reason the program needs but also ignores this line
end

---a non-player character plays a card
---@param game gamelib
---@return nil
local function playCardNPC(game)
  local player = game:getCurrentPlayer()
  local strat = strategy[player.name] or strategy.none
  local chosenCard = strat(game, player.name)
  game:playCard(player.name, chosenCard)
  narration.pressReturnTo("see what they play.")
end

---describe card the player played
---@param game gamelib
---@return string
local function describeCardPlayed(game)
  local player = game:getCurrentPlayer()
  local lastPlayedCard = game:getCardPlayedThisTurn()
  local subject = player.name
  if player.isVessel then
    subject = "You"
  end
  if lastPlayedCard then
    local lastPlayedCardName = cards.name(lastPlayedCard)
    return subject .. " played " .. lastPlayedCardName .. "!"
  else
    return "But nobody played a card..."
  end
end

---your turn
---@param game gamelib
---@param player player
---@return nil
local function yourTurn(game, player)
  ---@type NarrativeBeat[]
  local narrative = {
    {
      description = player.name .. "! It's your turn!",
      instruction = "choose a card to play"
    },
    {
      description = "Enter a number to play a card:",
      instruction = playCardPlease
    },
    {
      description = describeCardPlayed,
    },
  }
  game:narrate(narrative)
      :endTurn()
end

---their turn
---@param game gamelib
---@param player player
---@return nil
local function theirTurn(game, player)
  ---@type NarrativeBeat[]
  local narrative = {
    {
      description = "It's " .. player.name .. "'s turn!",
      instruction = playCardNPC
    },
    {
      description = describeCardPlayed,
    },
  }
  game:narrate(narrative)
      :endTurn()
end

local function playGame()
  os.execute('clear')
  narration.pressReturnTo('start game')
  local game = newGame
      :addPlayer('Kris')
      :addPlayer('Susie')
      :addPlayer('Ralsei')
      :addPlayer('Noelle')
      -- any set of 4 players can be used
      :playAs('Kris')
      -- :playAs('Susie')
      -- :playAs('Ralsei')
      -- :playAs('Noelle')
      :startGame()
  while not game:isOver() do
    local player = game:getCurrentPlayer()
    if player then
      if player.isVessel then
        yourTurn(game, player)
      else
        theirTurn(game, player)
      end
    end
  end
  game:endGame()
end

playGame()
