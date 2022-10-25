local speech   = require "lib.speech"
local cardGame = require "lib.cardGame"
local cards    = require "lib.cards"
local player   = require "lib.player"

-- get playable cards for a player
local function getPlayableCards(game, player)
  local playableCards = {}
  for _, card in ipairs(player.hand) do
    local rank = card:sub(1, -2)
    local suit = card:sub(-1)
    if rank == 'Q' and suit == '♠' then
      -- queen of spades is always playable
      table.insert(playableCards, card)
    elseif #game.trick == 0 then
      -- first card in trick is always playable
      table.insert(playableCards, card)
    else
      -- otherwise, playable cards must match suit of first card
      local firstCard = game.trick[1]
      local firstCardSuit = firstCard:sub(-1)
      if suit == firstCardSuit then
        table.insert(playableCards, card)
      end
    end
  end
  return playableCards
end

-- heads up display
local function render(game, player)
  print('┌──────────────────────┐')
  print('Hearts broken:', game.heartsBroken)
  print('Trick: [ ' .. table.concat(game.trick, ' ') .. ' ]')
  print(player.name .. "'s hand: [ " .. table.concat(player.hand, ', ') .. ' ]')
  print(player.name .. ' may play the following cards:')
  local playableCards = getPlayableCards(game, player)
  for i, card in ipairs(playableCards) do
    print('  ' .. i, card)
  end
end

-- take turn
local function yourTurn(game, player)
  speech.say(player.name .. "'s turn")
  render(game, player)
  io.write('Enter a number to play a card: ')
  local cardIdx = io.read('*n')
  local card = table.remove(player.hand, cardIdx)
  table.insert(game.trick, card)
  print(player.name .. ' plays ' .. cards.name(card:sub(1, -2), card:sub(-1)))
end

-- prompt to continue
local function promptContinue()
  io.write('(Press RETURN to continue)')
  _ = io.read()
  os.execute('clear')
end

local function playGame()
  local game = cardGame.init()
  promptContinue()
  player.add(game, 'Kris')
  player.add(game, 'Susie')
  player.add(game, 'Ralsei')
  player.add(game, 'Noelle')
  player.possess(game, 'Kris')
  cardGame.dealAllCards(game)
  yourTurn(game, game.players[1])
  -- printTableRecursive(game)
end

playGame()

-- printTable(createDeck())
-- add a turn order mechanic
-- when it becomes a player's turn
-- if they are the vessel, call the player's turn function
-- otherwise, call the npc's turn function
-- each time something happens, re
