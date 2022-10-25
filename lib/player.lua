---@class playerlib : table A library of functions for handling players.
local playerlib = {}

---@class player : table
---@field name string
---@field hand string[]
---@field tricksTaken string[][]
---@field score number
---@field isVessel boolean

---create a new player
---@param playerName string
---@return player
function playerlib.new(playerName)
  ---@type player
  local player = {
    name = playerName,
    hand = {},
    tricksTaken = {},
    score = 0,
    isVessel = false
  }
  return player
end

return playerlib
