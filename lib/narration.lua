local speech = require "lib.speech"
---@class NarrativeBeat : table
---@field description (fun(game: gamelib, player: player): string) | string
---@field instruction (fun(game: gamelib, player: player): nil) | string | nil

local narrationlib = {}

---prompt your player to continue
---@param message? string `(Press RETURN to ${message})`
function narrationlib.pressReturnTo(message)
  local doWhatever = message or 'continue'
  io.write('(Press RETURN ⏎ to ' .. doWhatever .. ')')
  _ = io.read()
end

---narrate
---@param game gamelib
---@param player player
---@param narrative NarrativeBeat[]
---@return nil
function narrationlib.narrate(game, player, narrative)
  ---normalize description to string
  ---@param description (fun(game: gamelib, player: player): string) | string
  ---@return string
  local function normalizeDescription(description)
    if type(description) == 'function' then
      description = description(game, player)
    end
    return description
  end

  ---prompt the player using the instruction
  ---@param instruction (fun(game: gamelib, player: player): nil) | string | nil
  ---@return nil
  local function prompt(instruction)
    if type(instruction) == 'function' then
      instruction(game, player)
    else
      narrationlib.pressReturnTo(instruction)
    end
  end

  local beat = 0
  while beat < #narrative do
    game:printHud()
    beat = beat + 1
    for i = 1, beat do
      local description = normalizeDescription(narrative[i].description)
      if i < beat then
        print("* " .. description)
      else
        speech.say(description)
      end
    end
    prompt(narrative[beat].instruction)
  end
end

return narrationlib
