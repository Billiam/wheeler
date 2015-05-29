return function (data)
  local f = loadstring("return (" .. data .. ")", nil, 't', {})
  
  if not f then
    return false
  end

  local count = 0
  debug.sethook(function ()
    count = count + 1
    if count >= 3 then
        error"cannot call functions"
    end
  end, "c")
  local ok, res = pcall(f)
  count = 0
  debug.sethook()
  return ok, res
end
