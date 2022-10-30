local speech = require "lib.speech"

---@class NarrativeBeat : table
---@field speaker? string
---@field description (fun(game: gamelib): string) | string
---@field instruction (fun(game: gamelib): nil) | string | nil

---@class NarrationLib : table
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
---@param narrative NarrativeBeat[]
---@return nil
function narrationlib.narrate(game, narrative)
  ---normalize description to string
  ---@param description (fun(game: gamelib): string) | string
  ---@return string
  local function normalizeDescription(description)
    if type(description) == 'function' then
      description = description(game)
    end
    return description
  end

  ---prompt the player using the instruction
  ---@param instruction (fun(game: gamelib): nil) | string | nil
  ---@return nil
  local function prompt(instruction)
    if type(instruction) == 'function' then
      instruction(game)
    else
      narrationlib.pressReturnTo(instruction)
    end
  end

  -- local beat = 0
  while game.narrativeMarker < #narrative do
    game:printHud()
    game.narrativeMarker = game.narrativeMarker + 1
    for i = 1, game.narrativeMarker do
      local description = normalizeDescription(narrative[i].description)
      local speaker = narrative[i].speaker or ""

      if i < game.narrativeMarker then
        if speaker ~= "" then
          print(speaker .. ": ")
        end
        print("* " .. description)
      else
        if speaker ~= "" then
          print(speaker .. ": ")
        end
        speech.say(description)
      end
    end
    prompt(narrative[game.narrativeMarker].instruction)
  end
end

return narrationlib
