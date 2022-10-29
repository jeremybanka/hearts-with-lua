local newGame   = require "lib.game"
local speech    = require "lib.speech"
local cards     = require "lib.cards"
local util      = require "lib.util"
local printer   = require "lib.printer"
local playerlib = require "lib.player"

_ = {}

---prompt your player to continue
---@param message? string `(Press RETURN to ${message})`
local function pressReturnTo(message)
  local doWhatever = message or 'continue'
  io.write('(Press RETURN ⏎ to ' .. doWhatever .. ')')
  _ = io.read()
end

---heads up display
---@param game gamelib
---@return nil
local function printHud(game)
  os.execute('clear')
  local vessels = game:getVessels()
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

---their turn
---@param game gamelib
---@param player player
---@return nil
local function theirTurn(game, player)
  printHud(game)
  speech.say("It's " .. player.name .. "'s turn.")
  pressReturnTo()
  local playableCards = game:getPlayableCards(player.name)
  local chosenCard = playableCards[1]
  game:playCard(player.name, chosenCard)
  printHud(game)
  print("* It's " .. player.name .. "'s turn.")
  speech.say(player.name .. " played " .. cards.name(chosenCard) .. "!")
  pressReturnTo()
  game:endTurn()
end

---@class NarrativeBeat : table
---@field description (fun(game: gamelib, player: player): string) | string
---@field instruction (fun(game: gamelib, player: player): nil) | string | nil

---prompt the player to play a card
---@param game gamelib
---@param player player
---@return nil
local function playCardPlease(game, player)
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

---describe card the player played
---@param game gamelib
---@param player player
---@return string
local function describeCardPlayed(game, player)
  local lastPlayedCard = game:getCardPlayedThisTurn()
  if lastPlayedCard then
    local lastPlayedCardName = cards.name(lastPlayedCard)
    return player.name .. " played " .. lastPlayedCardName .. "!"
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
      description = "It's your turn!",
      instruction = "choose a card to play"
    },
    {
      description = 'Enter a number to play a card:',
      instruction = playCardPlease
    },
    {
      description = describeCardPlayed,
    },
  }

  ---normalize description to string
  ---@param description (fun(game: gamelib, player: player): string) | string
  ---@return string
  local function normalizeDescription(description)
    if type(description) == 'function' then
      description = description(game, player)
    end
    return description
  end

  ---prompt the player using the instruction
  ---@param instruction (fun(game: gamelib, player: player): nil) | string | nil
  ---@return nil
  local function prompt(instruction)
    if type(instruction) == 'function' then
      instruction(game, player)
    else
      pressReturnTo(instruction)
    end
  end

  local beat = 0
  while beat < #narrative do
    printHud(game)
    beat = beat + 1
    for i = 1, beat do
      local description = normalizeDescription(narrative[i].description)
      if i < beat then
        print("* " .. description)
      else
        speech.say(description)
      end
    end
    prompt(narrative[beat].instruction)
    game:endTurn()
  end
end

local function playGame()
  os.execute('clear')
  pressReturnTo('start game')
  local game = newGame
      :addPlayer('Kris')
      :addPlayer('Susie')
      :addPlayer('Ralsei')
      :addPlayer('Noelle')
      :playAs('Noelle')
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
