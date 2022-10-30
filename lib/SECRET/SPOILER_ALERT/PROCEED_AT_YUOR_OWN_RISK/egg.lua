---@class EasterEggs
local egg = {}

---@param game gamelib
---@return nil
function egg.lancerPlayed(game)
  game:interruptNarrative({
    {
      speaker = "Lancer",
      description = "HO HO HO!! YOU JUST GOT LANCERED!",
      instruction = "acknowledge that you got lancered.",
    },
  }, 2)
end

return egg
