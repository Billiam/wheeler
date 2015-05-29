local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end
local Resources = {}

function Resources.init()
  Resources.font = Proxy(function(k) return Proxy(function(s) return love.graphics.newFont('font/' .. k .. '.otf', s) end) end)
end

function Resources.reload()
  Resources.init()
end

Resources.init()
return Resources