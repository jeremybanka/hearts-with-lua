---@class layout : table
local layout = {}

---write text into an limited-length cell
---@param size integer
---@param text string
---@return string
function layout.cell(size, text)
  local cell = text:sub(1, size)
  return cell .. string.rep(' ', size - #cell)
end

---write a line of limited-length cells
---@param size integer
---@param texts string[]
---@return string
function layout.line(size, texts)
  local line = ''
  for _, text in ipairs(texts) do
    line = line .. layout.cell(size, text)
  end
  return line
end

---write a table of limited-length cells
---@param size integer
---@param texts string[][]
---@return string[]
function layout.table(size, texts)
  local t = {}
  for _, text in ipairs(texts) do
    table.insert(t, layout.line(size, text))
  end
  return t
end

return layout
