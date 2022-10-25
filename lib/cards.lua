-- classic playing card deck
RANKS = {
  'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
}
SUITS = {
  'S', 'H', 'D', 'C'
}
FANCY_SUITS = {
  S = '♠', H = '♥', D = '♦', C = '♣'
}

---name card with funny exception for J♠ (Lancer)
---@param card string
---@return string
local function nameCard(card)
  local rank = card:sub(1, -2)
  local suit = card:sub(-1)
  if rank == 'J' and suit == 'S' then
    return 'Lancer'
  else
    return rank .. FANCY_SUITS[suit]
  end
end

return {
  name = nameCard,
  RANKS = RANKS,
  SUITS = SUITS
}
