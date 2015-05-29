local JoyDebug = {}
JoyDebug.mt = { __index = JoyDebug }

local font = love.graphics.newFont(10)

function JoyDebug.create()
  local instance = {}
  setmetatable(instance, JoyDebug.mt)
  return instance
end

function JoyDebug:setJoystick(joystick)
  self.joystick = joystick
end

function JoyDebug:show()
  if not self.joystick then
    return
  end
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font)
  local y = 0
  for i=1,self.joystick:getAxisCount() do
    love.graphics.print("Axis " .. i .. " : " .. self.joystick:getAxis(i), 0, y)
    y = y + font:getHeight()
  end
  for i=1,self.joystick:getButtonCount() do
    love.graphics.print("Button " .. i .. " : " .. (self.joystick:isDown(i) and "down" or "up"), 0, y)
    y = y + font:getHeight()
  end
end

return JoyDebug