local util      = require "lib.util"
local layout    = require "lib.layout"
local cards     = require "lib.cards"
---@class playerlib : table A library of functions for handling players.
local playerlib = {}



---create a new player
---@param playerName string
---@return player
function playerlib.new(playerName)
  ---@class player : table
  ---@field name string
  ---@field hand string[]
  ---@field tricksTaken string[][]
  ---@field points integer
  ---@field isVessel boolean
  local player = {
    name = playerName,
    hand = {},
    tricksTaken = {},
    points = 0,
    isVessel = false
  }

  ---get a player's hand as printable content
  ---@param player player
  ---@return string[] paragraphs
  function player.readHand(player)
    return util.map(
      player.hand,
      function(card)
        local cardName = cards.name(card)
        local cellSize = 8

        return layout.cell(cellSize, cardName)
      end
    )
  end

  ---player loses a card
  ---@param player player
  ---@param card string
  ---@return player
  function player.loseCard(player, card)
    local cardIdxInHand = util.indexOf(player.hand, card)
    table.remove(player.hand, cardIdxInHand)
    return player
  end

  return player
end

return playerlib
