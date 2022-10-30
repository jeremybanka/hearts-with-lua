local util = require "lib.util"
local cards = require "lib.cards"
---@class StrategyLib : table
local strategylib = {}

---Kris remembers all cards played, predicts the end of the round for each card in their hand
---Ralsei always plays the HIGHEST CARD he can and avoids playing hearts

---play the first card that's allowed
---@param game gamelib
---@param playerName string
---@return string
function strategylib.none(game, playerName)
  local playableCards = game:getPlayableCards(playerName)
  return playableCards[1]
end

---Susie always plays the LOWEST HEART she Can, or the HIGHEST NON-HEART she can
---@param game gamelib
---@param playerName string
---@return string
function strategylib.Susie(game, playerName)
  local playableCards = game:getPlayableCards(playerName)
  local hearts = cards.filterSuit(playableCards, "H")
  if #hearts > 0 then
    game:interruptNarrative({ {
      speaker = "Susie",
      description = "Ha! How d'ya like that?"
    } })
    return cards.getLowestRank(hearts)[1]
  else
    local card = cards.getHighestRank(playableCards)[1]
    if card == "QS" then
      game:interruptNarrative({ {
        speaker = "Susie",
        description = "Heh. Oops."
      } })
    end
    if (cards.getNumericRank(card) > 10) then
      game:interruptNarrative({ {
        speaker = "Susie",
        description = "Beat THAT, losers!"
      } })
    end
    return cards.getHighestRank(playableCards)[1]
  end
end

---assess threat of points
---@param game gamelib
---@param playerName string
---@return integer
function strategylib.assessThreat(game, playerName)
  local threat = game:getTrickPoints()
  local howManyCardsUnseen = #game.players - #util.entries(game.trick) - 1
  if howManyCardsUnseen == 0 then
    return threat
  end
  local queenHasBeenTaken = false
  for _, player in ipairs(game.players) do
    for _, trick in ipairs(player.tricksTaken) do
      for _, card in ipairs(util.entries(trick)) do
        if card == 'QS' then
          queenHasBeenTaken = true
          break
        end
        if queenHasBeenTaken then break end
      end
      if queenHasBeenTaken then break end
    end
    if queenHasBeenTaken then break end
  end
  local howManyCardsInHand = #game:getPlayer(playerName).hand
  local oddsOfSomeoneNotHavingSuit = 0.75 ^ howManyCardsInHand
  local pointsLikelyInThisRound = howManyCardsUnseen * oddsOfSomeoneNotHavingSuit
  if game.leadingSuit == "H" then
    pointsLikelyInThisRound = #game.players
  end
  if queenHasBeenTaken then
    threat = pointsLikelyInThisRound
  else
    if game.leadingSuit == "S" then
      threat = threat + pointsLikelyInThisRound + 13
      if game.trick.Kris == nil then
        game:interruptNarrative({ {
          speaker = playerName,
          description = "I'm not letting you give me the queen again like last time, Kris!"
        } })
      end
    else
      threat = threat + pointsLikelyInThisRound + 13 * oddsOfSomeoneNotHavingSuit
    end
  end
  return threat
end

---Noelle calculates the odds of getting points. she really doesn't want points.
---@param game gamelib
---@param playerName string
---@return string, NarrativeBeat?
function strategylib.Noelle(game, playerName)
  ---@type NarrativeBeat | nil
  local interruption = nil
  local threat = strategylib.assessThreat(game, playerName)
  local player = game:getPlayer(playerName)
  local playableCards = game:getPlayableCards(playerName)
  local playerMustFollowSuit = util.some(
    player.hand,
    function(card)
      return card:sub(-1) == game.leadingSuit
    end
  )
  -- print(threat)
  -- util.log(playableCards)
  local lowestCards = cards.getLowestRank(playableCards)
  local highestCards = cards.getHighestRank(playableCards)

  if threat >= 1 then
    if playerMustFollowSuit then
      -- print("lowest:", lowestCards[1])
      game:interruptNarrative({ {
        speaker = playerName,
        description = "I don't want to get points!",
      } })
      return lowestCards[1]
    end
  end
  if playerMustFollowSuit then
    if highestCards[1] == 'QS' then
      return highestCards[2] or cards.getSecondHighestRank(playableCards)[1]
    end
    -- print("highest:", highestCards[1])
    game:interruptNarrative({ {
      speaker = playerName,
      description = "Looks like the coast is clear. I'll play the highest card I can."
    } })
    return highestCards[1]
  end
  game:interruptNarrative({ {
    speaker = playerName,
    description = "Time to get rid of my high card. I'll play " .. cards.name(highestCards[1]) .. "..."
  } })
  -- print("highest:", highestCards[1])
  return highestCards[1]
end

return strategylib
