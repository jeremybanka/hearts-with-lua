local lib = {}

-- classic playing card deck
lib.RANKS = {
  'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
}
lib.SUITS = {
  'S', 'H', 'D', 'C'
}
lib.FANCY_SUITS = {
  S = '♠', H = '♥', D = '♦', C = '♣'
}

---name card with funny exception for J♠ (Lancer)
---@param card string
---@return string
function lib.name(card)
  local rank = card:sub(1, -2)
  local suit = card:sub(-1)
  if rank == 'J' and suit == 'S' then
    return 'LANCER'
  else
    return rank .. lib.FANCY_SUITS[suit]
  end
end

---get normalized numerical rank of card
---@param card string
---@return integer
function lib.getNumericRank(card)
  local rank = card:sub(1, -2)
  if rank == 'A' then
    return 14
  elseif rank == 'J' then
    return 11
  elseif rank == 'Q' then
    return 12
  elseif rank == 'K' then
    return 13
  else
    return math.floor(tonumber(rank) or 0)
  end
end

---hearts: get points for card
---@param card string
---@return integer
function lib.getPoints(card)
  -- hearts are worth 1 point
  if card:sub(-1) == 'H' then
    return 1
  end
  -- queen of spades is worth 13 points
  if card:sub(1, -2) == 'Q' and card:sub(-1) == 'S' then
    return 13
  end
  -- all other cards are worth 0 points
  return 0
end

return lib
