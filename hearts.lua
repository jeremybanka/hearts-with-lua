local newGame = require "lib.game"
local speech  = require "lib.speech"
local cards   = require "lib.cards"
local util    = require "lib.util"
local layout  = require "lib.layout"
local printer = require "lib.printer"
local player  = require "lib.player"



-- heads up display
local function render(game, player)
  print('┌──────────────────────┐')
  print('Hearts broken:', game.heartsBroken)
  print('Trick: [ ' .. table.concat(game.trick, ' ') .. ' ]')
  print(player.name .. "'s hand: [ " .. table.concat(player.hand, ', ') .. ' ]')
  print(player.name .. ' may play the following cards:')
  local playableCards = game:getPlayableCards(player.name)
  for i, card in ipairs(playableCards) do
    print('  ' .. i, cards.name(card))
  end
end

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

---prompt your player to continue
---@param message? string `(Press RETURN to ${message})`
local function whenReady(message)
  local doWhatever = message or 'continue'
  io.write('(Press RETURN to ' .. doWhatever .. ')')
  _ = io.read()
  os.execute('clear')
end

local function printHandOfP(game)
  local vessels = game:getVessels()
  ---@type
  local hands = util.map(
    vessels,
    function(vessel)
      return
    end
  )
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
  local vessels = game:getVessels()
  local you = vessels[1]
  local handContent = player.handContent(you)
  print("YOUR HAND:")
  printer.wrapping(handContent)
  print()
  print()
  local playerStats = game:getAllPlayerStats()
  printer.tabular(playerStats, { cellSize = 16, orientation = 'horizontal' })
  print()
  print()
  print("It's your turn!")

  -- yourTurn(game, game.players[1])
  -- render(game, game.players[1])
  -- printTableRecursive(game)
end

playGame()

-- printTable(createDeck())
-- add a turn order mechanic
-- when it becomes a player's turn
-- if they are the vessel, call the player's turn function
-- otherwise, call the npc's turn function
-- each time something happens, render
