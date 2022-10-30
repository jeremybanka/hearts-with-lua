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
  local suit = lib.getSuit(card)
  if rank == 'J' and suit == 'S' then
    return 'LANCER'
  elseif rank == 'R' and suit == 'K' then
    return 'ROUXLS KAARD'
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

---get lowest ranked from a list of cards
---@param cards string[]
---@return string[]
function lib.getLowestRank(cards)
  local lowestRank = 15
  local lowestCards = {}
  for _, card in ipairs(cards) do
    local rank = lib.getNumericRank(card)
    if rank == lowestRank then
      table.insert(lowestCards, card)
    end
    if rank < lowestRank then
      lowestRank = rank
      lowestCards = { card }
    end
  end
  return lowestCards
end

---get highest ranked from a list of cards
---@param cards string[]
---@return string[]
function lib.getHighestRank(cards)
  local highestRank = 0
  local highestCards = {}
  for _, card in ipairs(cards) do
    local rank = lib.getNumericRank(card)
    if rank == highestRank then
      table.insert(highestCards, card)
    end
    if rank > highestRank then
      highestRank = rank
      highestCards = { card }
    end
  end
  return highestCards
end

---get second highest ranked from a list of cards
---@param cards string[]
---@return string[]
function lib.getSecondHighestRank(cards)
  local highestRank = 0
  local highestRankCards = {}
  local secondHighestRank = 0
  local secondHighestCards = {}
  for _, card in ipairs(cards) do
    local rank = lib.getNumericRank(card)
    if rank == highestRank then
      table.insert(highestRankCards, card)
    elseif rank > highestRank then
      secondHighestRank = highestRank
      secondHighestCards = highestRankCards
      highestRank = rank
      highestRankCards = { card }
    elseif rank == secondHighestRank then
      table.insert(secondHighestCards, card)
    elseif rank > secondHighestRank then
      secondHighestRank = rank
      secondHighestCards = { card }
    end
  end
  return secondHighestCards
end

---filter to cards with a certain suit
---@param cards string[]
---@param suit string
---@return string[]
function lib.filterSuit(cards, suit)
  local filtered = {}
  for _, card in ipairs(cards) do
    if lib.getSuit(card) == suit then
      table.insert(filtered, card)
    end
  end
  return filtered
end

---filter to cards without a certain suit
---@param cards string[]
---@param suit string
---@return string[]
function lib.filterOutSuit(cards, suit)
  local filtered = {}
  for _, card in ipairs(cards) do
    if lib.getSuit(card) ~= suit then
      table.insert(filtered, card)
    end
  end
  return filtered
end

---get suit of card
---@param card string
---@return string
function lib.getSuit(card)
  -- if card == 'RK' then error("ERROR: THIS CARD DOESN'T HAVE A SUIT") end
  return card:sub(-1)
end

---hearts: get points for card
---@param card string
---@return integer
function lib.getPoints(card)
  -- hearts are worth 1 point
  if lib.getSuit(card) == 'H' then
    return 1
  end
  -- queen of spades is worth 13 points
  if card:sub(1, -2) == 'Q' and lib.getSuit(card) == 'S' then
    return 13
  end
  if card:sub(1, -2) == 'R' and lib.getSuit(card) == 'K' then
    return math.maxinteger
  end
  -- all other cards are worth 0 points
  return 0
end

return lib
