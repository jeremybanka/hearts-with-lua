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

---port of Array.prototype.every from JavaScript
---@generic Value
---@param values Value[]
---@param doesMatch fun(value: Value, index: integer, arr: any[]): boolean
function util.every(values, doesMatch)
  for i, v in ipairs(values) do
    if not doesMatch(v, i, values) then
      return false
    end
  end
  return true
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

---port of Array.prototype.filter from JavaScript
---@generic Value
---@param values Value[]
---@param doesMatch fun(value: Value, index: integer, arr: Value[]): boolean
---@return Value[]
function util.filter(values, doesMatch)
  local result = {}
  for i, v in ipairs(values) do
    if doesMatch(v, i, values) then
      table.insert(result, v)
    end
  end
  return result
end

---port of Array.prototype.contains from JavaScript
---@generic Value
---@param values Value[]
---@param value Value
---@return boolean
function util.contains(values, value)
  return util.indexOf(values, value) ~= -1
end

---port of Array.prototype.map from JavaScript
---@generic Input, Output
---@param values Input[]
---@param transform fun(value: Input, index: integer, arr: Input[]): Output
---@return Output[]
function util.map(values, transform)
  local result = {}
  for i, v in ipairs(values) do
    table.insert(result, transform(v, i, values))
  end
  return result
end

---@class entry<V>: { key: string; val: V }

---port of Object.entries from JavaScript
---@generic Value
---@param obj { [string]: Value }
---@return ({ key: string; val: Value })[]
function util.entries(obj)
  local result = {}
  for key, val in pairs(obj) do
    table.insert(result, { key = key, val = val })
  end
  return result
end

---merge two tables, overwriting values in the first table with values in the second table
---@generic T1, T2 : table
---@param t1 T1
---@param t2 T2
---@return T1 & T2
function util.merge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

---invert the nesting structure of a nested Array
---@generic Value
---@param values Value[][]
---@return Value[][]
function util.invert(values)
  local result = {}
  for i1, v1 in ipairs(values) do
    for i2, v2 in ipairs(v1) do
      if not result[i2] then
        result[i2] = {}
      end
      result[i2][i1] = v2
    end
  end
  return result
end

---@param t table
---@param d? integer
---@return nil
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

---@param t unknown
---@return nil
function util.log(t)
  print('LOG ------------------')
  if type(t) == 'table' then
    util.printTableRecursive(t)
  else
    print(t)
  end
  print('----------------------')
end

---port of String.prototype.split from JavaScript
---@param str string
---@param sep string
---@return string[]
function util.split(str, sep)
  local result = {}
  local start = 1
  local finish = string.find(str, sep, start, true)
  while finish do
    table.insert(result, string.sub(str, start, finish - 1))
    start = finish + #sep
    finish = string.find(str, sep, start, true)
  end
  table.insert(result, string.sub(str, start))
  return result
end

return util
