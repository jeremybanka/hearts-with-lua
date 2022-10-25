-- classic playing card deck
RANKS = {
  'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
}
SUITS = {
  '♠', '♥', '♦', '♣'
}

--name card with funny exception for J♠ (Lancer)
local function nameCard(rank, suit)
  if rank == 'J' and suit == '♠' then
    return 'Lancer'
  else
    return rank .. suit
  end
end

return {
  name = nameCard,
  RANKS = RANKS,
  SUITS = SUITS
}
