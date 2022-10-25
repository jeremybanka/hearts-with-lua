local function printTableRecursive(t, d)
  local depth = d or 0
  local indent = string.rep(' ', depth * 2)
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(indent .. k .. ':')
      printTableRecursive(v, depth + 1)
    else
      print(indent .. k, v)
    end
  end
end

return {
  printTableRecursive = printTableRecursive
}
