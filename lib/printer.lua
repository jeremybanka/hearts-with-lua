local util = require "lib.util"
local layout = require "lib.layout"
---@class printerlib : table A library of printing macros.
local printerlib = {}

---print an array of lines
---@param lines string[]
---@return nil
function printerlib.lines(lines)
  for _, v in pairs(lines) do
    print(v)
  end
end

---@class TabularPrinterOptions
---@field cellSize? integer
---@field orientation? 'vertical' | 'horizontal'
printerlib.defaultTablePrinterOptions = {
  cellSize = 16,
  orientation = 'vertical'
}
---print tabular data
---@param data string[][]
---@param options? TabularPrinterOptions
---@return nil
function printerlib.tabular(data, options)
  options = options or {}
  options = util.merge(printerlib.defaultTablePrinterOptions, options)
  if options.orientation == 'horizontal' then
    data = util.invert(data)
  end
  printerlib.lines(layout.table(options.cellSize, data))
end

---@class WrappingPrinterOptions
---@field lineLength? integer
printerlib.defaultWrappingPrinterOptions = {
  lineLength = 80,
  lineSpacing = 1,
  indent = 0,
  indentFirstLine = 0
}
---print wrapping content
---@param content string[]
---@param options? WrappingPrinterOptions
---@return nil
function printerlib.wrapping(content, options)
  options = options or {}
  options = util.merge(printerlib.defaultWrappingPrinterOptions, options)
  ---@type string[]
  local lines = { "" }
  local length = 0
  for _, v in pairs(content) do
    if length + #v > options.lineLength then
      table.insert(lines, '')
      length = 0
    end
    lines[#lines] = lines[#lines] .. v
    length = length + #v
  end
  printerlib.lines(lines)
end

---print a paragraph of content
---@param text string
---@param options? WrappingPrinterOptions
---@return nil
function printerlib.paragraph(text, options)
  options = options or {}
  local content = util.map(
    util.split(text, ' '),
    function(word)
      return word .. ' '
    end
  )
  printerlib.wrapping(content, options)
end

return printerlib
