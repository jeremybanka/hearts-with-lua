local newGame   = require "lib.game"
local speech    = require "lib.speech"
local cards     = require "lib.cards"
local util      = require "lib.util"
local printer   = require "lib.printer"
local playerlib = require "lib.player"

_ = {}

---prompt your player to continue
---@param message? string `(Press RETURN to ${message})`
local function whenReady(message)
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
  whenReady()
  local playableCards = game:getPlayableCards(player.name)
  local chosenCard = playableCards[1]
  game:playCard(player.name, chosenCard)
  printHud(game)
  print("* It's " .. player.name .. "'s turn.")
  speech.say(player.name .. " played " .. cards.name(chosenCard) .. "!")
  whenReady()
  game:endTurn()
end

---your turn
---@param game gamelib
---@param player player
---@return nil
local function yourTurn(game, player)

  printHud(game)
  speech.say("It's your turn!")
  whenReady("choose a card to play")

  local playableCards = game:getPlayableCards(player.name)
  printHud(game)
  print("* It's your turn!")
  speech.say('Enter a number to play a card: ')
  local prettyPlayableCards = util.map(
    playableCards,
    function(card)
      return cards.name(card)
    end
  )
  printer.list(prettyPlayableCards, { indentFirstLine = 2, })
  print("(Press the number of the card you wish to play, then press RETURN ⏎)")
  io.write("> ")
  local cardIdx = io.read('*n')
  local chosenCard = playableCards[cardIdx] or playableCards[1]
  game:playCard(player.name, chosenCard)
  _ = io.read() -- for some reason the program needs but ignores this line

  printHud(game)
  print("* It's your turn!")
  speech.say("You played " .. cards.name(chosenCard) .. ".")
  whenReady()
  game:endTurn()

end

local function playGame()
  os.execute('clear')
  -- whenReady('start game')
  local game = newGame
      :addPlayer('Kris')
      :addPlayer('Susie')
      :addPlayer('Ralsei')
      :addPlayer('Noelle')
      :playAs('Kris')
      :dealAllCards()

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
  print('Game over!')
end

playGame()
