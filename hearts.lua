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

---@class Beat : table
---@field desc (fun(game: gamelib, player: player): string) | string
---@field prompt (fun(game: gamelib, player: player): nil) | string | nil

---prompt the player to play a card
---@param game gamelib
---@param player player
---@return nil
local function promptCard(game, player)
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
  ---@type Beat[]
  local narrative = {
    {
      desc = "It's your turn!",
      prompt = "choose a card to play"
    },
    {
      desc = 'Enter a number to play a card:',
      prompt = promptCard
    },
    {
      desc = describeCardPlayed,
    },
  }

  -- section 1
  printHud(game)
  local desc1 = narrative[1].desc
  if type(desc1) == 'function' then
    desc1 = desc1(game, player)
  end
  speech.say(desc1)
  local prompt = narrative[1].prompt
  if type(prompt) == 'function' then
    prompt(game, player)
  else
    pressReturnTo(prompt)
  end

  -- section 2
  printHud(game)
  local desc2 = narrative[2].desc
  if type(desc2) == 'function' then
    desc2 = desc2(game, player)
  end
  print("* " .. desc1)
  speech.say(desc2)
  local prompt = narrative[2].prompt
  if type(prompt) == 'function' then
    prompt(game, player)
  else
    pressReturnTo(prompt)
  end

  -- section 3
  printHud(game)
  local desc3 = narrative[3].desc
  if type(desc3) == 'function' then
    desc3 = desc3(game, player)
  end
  print("* " .. desc1)
  print("* " .. desc2)
  speech.say(desc3)
  local prompt = narrative[3].prompt
  if type(prompt) == 'function' then
    prompt(game, player)
  else
    pressReturnTo(prompt)
  end

  game:endTurn()
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
