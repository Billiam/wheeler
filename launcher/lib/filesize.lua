local units = {'B', 'KB', 'MB', 'GB', 'TB'}
return function(bytes, places)
  places = places or 2
  if bytes == 0 then
    return '0B'
  end
  local base = math.log(bytes) / math.log(1024)
  local floored = math.floor(base)
  local unit_amount = math.pow(1024, base - floored)

  local place_mod = math.pow(10, places)
  return string.format("%." .. places .. 'f%s', math.floor(unit_amount * place_mod + 0.5)/place_mod, units[floored + 1])
end