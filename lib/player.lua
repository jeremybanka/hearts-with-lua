-- add a player to the game
local function addPlayer(game, playerName)
  local player = {
    name = playerName,
    hand = {},
    tricksTaken = {},
    score = 0,
    isVessel = false
  }
  table.insert(game.players, player)
end

-- possess player
local function possessPlayer(game, playerName)
  for _, player in ipairs(game.players) do
    if player.name == playerName then
      player.isVessel = true
    end
  end
end

-- is the player you?
local function isYou(player)
  return player.isVessel
end

return {
  add = addPlayer,
  possess = possessPlayer,
  isYou = isYou
}
