local util        = require "lib.util"
local cards       = require "lib.cards"
local egg         = require "lib.SECRET.SPOILER_ALERT.PROCEED_AT_YUOR_OWN_RISK.egg"
---@class StrategyLib : table
local strategylib = {}

---no strategy: play the first card that's allowed
---@param game gamelib
---@param playerName string
---@return string
function strategylib.none(game, playerName)
  local playableCards = game:getPlayableCards(playerName)
  return playableCards[1]
end

---Susie always plays the LOWEST HEART she Can, or the HIGHEST NON-HEART she can
---she likes to brag about dumping points and playing face cards
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
      } }, 2)
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

---Ralsei always plays the HIGHEST CARD he can and avoids playing hearts
---Importantly, he considers who is likely to take the trick and says sorry
---@param game gamelib
---@param playerName string
---@return string
function strategylib.Ralsei(game, playerName)
  local trickIsEmpty = #util.entries(game.trick) == 0
  local taker, takersCard = game:getPlayer(playerName), nil
  if not trickIsEmpty then
    taker, takersCard = game:getTrickTaker()
  end
  local trickIsPainted = game:getTrickPoints() > 0
  local playableCards = game:getPlayableCards(playerName)
  local niceCards = cards.getHighestRank(cards.filterOutSuit(playableCards, "H"))
  local isBeingNice = #niceCards ~= 0
  local chosenCard = niceCards[1] or cards.getHighestRank(playableCards)[1]
  local isRalseiGonnaWin = game:mayWinTrick(chosenCard)
  local mayWin = isRalseiGonnaWin == "maybe"
  local willWin = isRalseiGonnaWin == "yes"
  local wontWin = isRalseiGonnaWin == "no"
  if isBeingNice then
    if takersCard ~= nil then
      if mayWin or willWin then
        game:interruptNarrative({ {
          speaker = "Ralsei",
          description = "Sorry, " .. taker.name .. "! Looks like I'm gonna take this one!"
        } })
        if trickIsPainted then
          game:interruptNarrative({ {
            speaker = playerName,
            description = "I'm not worried about getting points. It's just fun to play!"
          } })
        end
      end
    end
    if taker.name == "Susie" and wontWin then
      game:interruptNarrative({ {
        speaker = "Ralsei",
        description = "Nice one, Susie! I'll get you next time!"
      } })
    end
    return cards.getHighestRank(niceCards)[1]
  else
    if trickIsEmpty then
      game:interruptNarrative({ {
        speaker = playerName,
        description = "Looks like I've got no choice..."
      }, {
        speaker = playerName,
        description = "But don't worry, I'm sure this will end up being my trick!"
      } })
    elseif wontWin then
      game:interruptNarrative({ {
        speaker = playerName,
        description = "Oh no... Sorry " .. taker.name .. "..."
      } })
    end
    return cards.getHighestRank(playableCards)[1]
  end
end

---fight or flight: noelle assesses the threat of points
--- [LMAO] (I Made Her Brain A Robot One LOL)
---@param game gamelib
---@param playerName string
---@return integer
function strategylib.NoelleAssessThreat(game, playerName)
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
  local threat = strategylib.NoelleAssessThreat(game, playerName)
  local player = game:getPlayer(playerName)
  local playableCards = game:getPlayableCards(playerName)
  local playerMustFollowSuit = util.some(
    player.hand,
    function(card)
      return cards.getSuit(card) == game.leadingSuit
    end
  )
  -- print(threat)
  -- util.log(playableCards)
  local lowestCards = cards.getLowestRank(playableCards)
  local highestCards = cards.getHighestRank(playableCards)

  if threat >= 1 then
    local chosenCard = lowestCards[1]
    if game:mayWinTrick(chosenCard) == "maybe" then
      -- print("lowest:", lowestCards[1])
      game:interruptNarrative({ {
        speaker = playerName,
        description = "I hope this is low enough to get by...",
      } })
    end
    return chosenCard
  end
  local chosenCard = highestCards[1]
  if playerMustFollowSuit then
    if chosenCard == 'QS' then
      local fallbackCard = cards.getSecondHighestRank(playableCards)[1]
      if fallbackCard == nil then
        if game:mayWinTrick('QS') == "maybe" then
          game:interruptNarrative({ {
            speaker = playerName,
            description = "Eek! It looks like I only have one choice!",
          }, {
            speaker = playerName,
            description = "This could be bad...",
          } })
          return highestCards[1]
        end
      else
        game:interruptNarrative({ {
          speaker = playerName,
          description = "I'm gonna play--",
        }, {
          speaker = playerName,
          description = "--oh, no. Not that one.",
        } })
        return fallbackCard
      end
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
  local highestSafeCard = util.filter(
    highestCards,
    function(card)
      return not util.contains({ 'QS', 'KS', 'AS' }, card) and cards.getSuit(card) ~= 'H'
    end
  )[1] or cards.getSecondHighestRank(playableCards)[1]
  return highestSafeCard
end

return strategylib
