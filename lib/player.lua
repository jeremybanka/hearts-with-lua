local util      = require "lib.util"
local layout    = require "lib.layout"
local cards     = require "lib.cards"
---@class playerlib : table A library of functions for handling players.
local playerlib = {}

---@class player : table
---@field name string
---@field hand string[]
---@field tricksTaken string[][]
---@field score integer
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

---get a player's hand as printable content
---@param player player
---@return string[] paragraphs
function playerlib.handContent(player)
  return util.map(
    player.hand,
    function(card)
      local cardName = cards.name(card)
      local cellSize = 8

      return layout.cell(cellSize, cardName)
    end
  )
end

return playerlib
