local util    = require "lib.util"
local printer = require "lib.printer"
local cards   = require "lib.cards"
local deck    = require "lib.deck"
---@class EasterEggs
local egg     = {}


---@param game gamelib
---@return nil
function egg.lancerPlayed(game)
  ---@type NarrativeBeat
  local youGotLancered = {
    speaker = "Lancer",
    description = "HO HO HO!! YOU JUST GOT LANCERED!",
    instruction = "acknowledge that you got lancered.",
  }
  ---@type table<"Kris" | "Susie" | "Ralsei" | "Noelle", NarrativeBeat[]>
  local responsesToLancer = {
    Kris = { {
      speaker = "Kris",
      description = "...",
    } },
    Susie = { {
      speaker = "Susie",
      description = "Yeah! Get Lancered, nerds!",
    } },
    Ralsei = { {
      speaker = "Ralsei",
      description = "Oh no! I'm sorry!",
    } },
    Noelle = { {
      speaker = "Noelle",
      description = "Fahaha! I got dancered! XD",
    }, {
      speaker = "Noelle",
      description = "Wait, have we met?"
    }, {
      speaker = "Lancer",
      description = "My name is Lancer, and I'm here to say! I'm gonna Lancer. You!",
    }, {
      speaker = "Lancer",
      description = "Today!",
    } }
  }
  local player = game:getCurrentPlayer()
  local response = responsesToLancer[player.name]
  local interruptionWithResponse = util.concat({ youGotLancered }, response)
  game:interruptNarrative(interruptionWithResponse, 2)
end

SECRET_FLAG_ROUXLS_RUINS_THE_GAME = false
SECRET_TALLY_ROUXLS_ROUND_COUNTER = 0
SECRET_FLAG_ROUXLS_INTRO_COMPLETE = false
SECRET_FLAG_ROUXLS_ADDS_MECHANICS = false
SECRET_FLAG_RALSEI_GIVES_FEEDBACK = false

---@param game gamelib
---@return nil
function egg.rouxlsPlayed(game)
  local playerName = game:getCurrentPlayer().name
  ---playing rouxls basically ruins the game,
  ---so you have the option to discard him if you want
  ---@param g gamelib
  ---@return nil
  local function chooseRoute(g)
    printer.list({
      "I am going to play Rouxls Card",
      "I do not play Rouxls Card",
    }, { indentFirstLine = 2, })
    print("(Press the number of your decision, then press RETURN ⏎)")
    io.write("> ")
    local choiceIdx = io.read('*n')
    if (choiceIdx == 1) then
      SECRET_FLAG_ROUXLS_RUINS_THE_GAME = true
    else
      local you = g:getCurrentPlayer()
      game.trick[you.name] = nil
      game.narrativeMarker = 0
    end

    _ = io.read() -- for some reason the program needs but also ignores this line
  end

  ---@type NarrativeBeat[]
  local digression = {
    {
      description = "This card isn't supposed to be here. What do you want to do?",
      instruction = chooseRoute,
    },
    {
      speaker = "Ralsei",
      description = "Um, " .. playerName .. "?",
    }, {
      speaker = "Ralsei",
      description = "I don't think that card is supposed to be in the deck...",
    }, {
      description = "The table begins to shudder...",
      instruction = "pay attention",
    }, {
      description = "An piercing drone fills the air...",
      instruction = "wait for Rouxls to finish showing up",
    }, {
      description = function()
        if not util.some(game.players, function(p) return p.name == "Rouxls" end) then
          game:addPlayer("Rouxls")
          local rouxls = game:getPlayer("Rouxls")
          rouxls.hand = deck.create()
        end
        return "A white glow descends from somewhere on the ceiling..."
      end,
      instruction = "continue waiting",
    }, {
      speaker = "Rouxls Kaard",
      description = "Well, well. Wouldstn't it appeare that thine WORMS hath crosset my patheth onest againe!"
    }, {
      speaker = "Susie",
      description = "Ugh. Scram, Rouxls!",
    }, {
      speaker = "Rouxls Kaard",
      description = "I am not one to be scrammed, thou worm! But if ye play thouen cardes right, namely, thour's truthly, I may be persuaded to let ye gain the uppered hand!",
    }, {
      speaker = "Rouxls Kaard",
      description = "Let's the game beginth!",
    },
    --  {
    --   description = "The table begins to shake violently...",
    --   instruction = "wait for Rouxls to finish leaving",
    -- }, {
    --   description = "(Rouxls left.)"
    -- }, {
    --   speaker = "Noelle",
    --   description = "Who was that?",
    -- }
  }
  game:interruptNarrative(digression)
end

---rouxls scores the round and decides whose turn it will be
---@param game gamelib
---@return nil
function egg.rouxlsScores(game)
  if not SECRET_FLAG_ROUXLS_INTRO_COMPLETE then
    ---@type NarrativeBeat[]
    local rouxlsScoringIntro = {
      {
        speaker = "Rouxls Kaard",
        description = "Scoring time! I shall now tally the roundeth!",
      }, {
        speaker = "Rouxls Kaard",
        description = "Any player who arest samesies as me shalt be awardeth points of merit.",
      }, {
        speaker = "Rouxls Kaard",
        description = "Remembere ye well, come game's end, yon player with the manyest pointes will be decreed the winningmost!",
      }
    }
    SECRET_FLAG_ROUXLS_INTRO_COMPLETE = true
    game:narrate(rouxlsScoringIntro)
  end
  ---roulxs basically just gives points to the players who play the same rank of card he played
  ---he refers to this as "samesies". "Samesies" is worth 100 points. It's a great, fair game that's really fun.
  if (game.trick.Rouxls ~= nil) then
    local rouxls = game:getPlayer("Rouxls")
    local rouxlsCard = game.trick.Rouxls
    local rouxlsRank = cards.getNumericRank(rouxlsCard)
    local rouxlsScore = 100
    local samesies = util.filter(game.players,
      function(p)
        local card = game.trick[p.name]
        return card ~= nil and cards.getNumericRank(card) == rouxlsRank and p.name ~= "Rouxls"
      end)

    -- rouxls is disappointed if nobody played the same card as him
    local samesiesMessage = "Gah! No player hath playedest the same card as mine!"
    if SECRET_FLAG_ROUXLS_ADDS_MECHANICS then
      samesiesMessage = "Gah! No player hath playedest the same card as mine! I REBUKE THOU!"
    end
    if #samesies > 0 then
      local samesiesNames = util.map(samesies, function(p) return p.name end)
      if #samesiesNames == 1 then
        samesiesMessage = "Samesies! " ..
            samesiesNames[1] .. " hath playedest the same card as mine! I awarde ye a hundreth points of merit!"
      else
        local lastSamesiesName = table.remove(samesiesNames)
        local samesiesList = table.concat(samesiesNames, ", ") .. " and " .. lastSamesiesName
        samesiesMessage = "Samesies! " ..
            samesiesList .. " hath playedest the same card as mine! I awardeth thou one onehundreth points of merit!"
      end
    end

    game:narrate({ { description = samesiesMessage } })
    if #samesies == 0 and SECRET_FLAG_ROUXLS_ADDS_MECHANICS then
      -- lower all points if nobody played the same card as rouxls
      for _, p in ipairs(game.players) do
        p.points = p.points - 10000


      end
      game:narrate({ {
        speaker = "Ralsei",
        description = "I'm not sure if REBUKE a good idea, Mr. Rouxls, but I admire your commitment to fun!"
      } })
    end
    if SECRET_TALLY_ROUXLS_ROUND_COUNTER > 3 and SECRET_FLAG_ROUXLS_ADDS_MECHANICS == false then
      game:narrate({ {
        speaker = "Susie",
        description = "What the hell, Rouxls? There's no way we can get more points than you!"
      }, {
        speaker = "Rouxls Kaard",
        description = "Whilst I believeth the game is fair, I doth not believen't that the game is quite enough fun. I shall addeth a mechanism to bemake the game more fun!"
      }, {
        speaker = "Rouxls Kaard",
        description = "Let's the game beginth!",
      } })
      SECRET_FLAG_ROUXLS_ADDS_MECHANICS = true
    end
    if #samesies > 0 then
      for _, p in ipairs(samesies) do
        p.points = p.points + rouxlsScore
      end
      rouxls.points = rouxls.points + rouxlsScore
    end
  end
  SECRET_TALLY_ROUXLS_ROUND_COUNTER = SECRET_TALLY_ROUXLS_ROUND_COUNTER + 1
end

---@param game gamelib
---@return boolean
function egg.rouxlsEndGame(game)
  local playersWithEmptyHands = util.filter(
    game.players,
    function(p) return #p.hand == 0 end
  )
  if #playersWithEmptyHands == #game.players - 2 then
    return true
  end
  return false
end

return egg
