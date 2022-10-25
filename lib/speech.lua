-- print line character by character
local function say(line, speed)
  io.write('* ')
  for i = 1, #line do
    io.write(line:sub(i, i))
    io.flush()
    os.execute('sleep ' .. (speed or 0.02))
  end
  print()
end

return {
  say = say
}
