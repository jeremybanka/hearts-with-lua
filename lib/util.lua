---@class util : table A library of utility functions.
local util = {}

---port of Array.prototype.some from JavaScript
---@generic Value
---@param values Value[]
---@param doesMatch fun(value: Value, index: integer, arr: any[]): boolean
function util.some(values, doesMatch)
  for i, v in ipairs(values) do
    if doesMatch(v, i, values) then
      return true
    end
  end
  return false
end

---port of Array.prototype.indexOf from JavaScript
---@generic Value
---@param values Value[]
---@param value Value
---@return integer
function util.indexOf(values, value)
  for i, v in ipairs(values) do
    if v == value then
      return i
    end
  end
  return -1
end

function util.printTableRecursive(t, d)
  local depth = d or 0
  local indent = string.rep(' ', depth * 2)
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(indent .. k .. ':')
      util.printTableRecursive(v, depth + 1)
    else
      print(indent .. k, v)
    end
  end
end

return util
