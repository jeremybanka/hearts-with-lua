local util = require "lib.util"
---@class EasterEggs
local egg = {}


---@param game gamelib
---@return nil
function egg.lancerPlayed(game)
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
      description = "Fahaha! Have we met?",
    }, {
      speaker = "Lancer",
      description = "I'm Lancer, and I'm here to say, I'm gonna Lancer you today!",
    } }
  }
  local player = game:getCurrentPlayer()
  local response = responsesToLancer[player.name]
  local interruptionWithResponse = util.concat({ youGotLancered }, response)
  game:interruptNarrative(interruptionWithResponse, 2)
end

return egg
