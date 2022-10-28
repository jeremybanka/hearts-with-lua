local newGame   = require "lib.game"
local speech    = require "lib.speech"
local cards     = require "lib.cards"
local util      = require "lib.util"
local layout    = require "lib.layout"
local printer   = require "lib.printer"
local playerlib = require "lib.player"

---take turn
local function yourTurn(game, player)
  speech.say(player.name .. "'s turn")
  render(game, player)
  io.write('Enter a number to play a card: ')
  local cardIdx = io.read('*n')
  local chosenCard = game:getPlayableCards(player.name)[cardIdx]
  if chosenCard then
    local cardIdxInHand = util.indexOf(player.hand, chosenCard)
    local card = table.remove(player.hand, cardIdxInHand)
    table.insert(game.trick, card)
    print(player.name .. ' plays ' .. cards.name(card))
  else
    speech.say('Invalid card')
  end
end

-- heads up display
local function printHud(game)
  local vessels = game:getVessels()
  local you = vessels[1]
  local handContent = playerlib.handContent(you)
  print("YOUR HAND:")
  printer.wrapping(handContent)
  print()
  print()
  local playerStats = game:getAllPlayerStats()
  printer.tabular(playerStats, { cellSize = 16, orientation = 'horizontal' })
  print()
  print()
  print("It's your turn!")
end

---prompt your player to continue
---@param message? string `(Press RETURN to ${message})`
local function whenReady(message)
  local doWhatever = message or 'continue'
  io.write('(Press RETURN to ' .. doWhatever .. ')')
  _ = io.read()
  os.execute('clear')
end

local function playGame()
  whenReady('start game')
  local game = newGame
      :addPlayer('Kris')
      :addPlayer('Susie')
      :addPlayer('Ralsei')
      :addPlayer('Noelle')
      :playAs('Kris')
      :dealAllCards()
  printHud(game)

  while not game:isOver() do
    local player = game:getCurrentPlayer()
    yourTurn(game, player)
    whenReady('continue')
    printHud(game)
  end

  print('Game over!')
end

playGame()

-- printTable(createDeck())
-- add a turn order mechanic
-- when it becomes a player's turn
-- if they are the vessel, call the player's turn function
-- otherwise, call the npc's turn function
-- each time something happens, render
