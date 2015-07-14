local String = {}

function String.truncate(str, length, suffix)
  suffix = suffix or '...'
  
  if length and str:len() > length then
    return str:sub(1, length - suffix:len()) .. suffix
  end
  
  return str
end

function String.truncate_lines(str, lines, width, font, suffix)
  if not width or lines == 1 then return string end
  
  lines = lines or 1
  font = font or love.graphics.getFont()
  suffix = suffix or '...'
  
  local suff_len = #suffix
  while select(2, font:getWrap(str, width)) > lines and str ~= suffix do
    str = str:sub(1, - (suff_len + 2)) .. suffix
  end
  return str
end

return String
