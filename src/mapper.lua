local Mapper = {
  joysticks = {}
}
Mapper.mt = { __index = Mapper }

function Mapper.create(controller, config)
  local instance = {
    joysticks = {},
    controller = controller,
    
    userConfig = config,
    
    config = {
      button = {},
      axis = {}
    }
  }

  setmetatable(instance, Mapper.mt)

  instance:initJoysticks()
  instance:initConfig()  
  
  return instance
end

function Mapper:initJoysticks()
  self.joysticks = {}
  for i,joystick in ipairs(love.joystick.getJoysticks()) do
    self.joysticks[joystick:getGUID()] = joystick  
  end
end

function Mapper:initConfig()
  self:parseConfig(self.userConfig)
end

function Mapper:parseConfig(config)
  -- group key configs by input type and joystick
  for action, input in pairs(config) do
    local joystick = self.joysticks[input.joystick]
    if joystick then
      self.config[input.type] = self.config[input.type] or {}
      self.config[input.type][joystick] = self.config[input.type][joystick] or {}
      self.config[input.type][joystick][input.input] = { action = action, invert = input.invert }
    end
  end
end

function Mapper:addJoystick(joystick)
  if self.userConfig[joystick:getID()] then
    self.joysticks[joystick:getID()] = joystick
  end
  self:initConfig()
end

function Mapper:setControls(types, value)
  for index,type in ipairs(types) do
    self:setControl(type, value)
  end
end

function Mapper:setControl(type, value)
  self.controller:set(type.action, value)
end

function Mapper:setButton(joystick, button, value)
  local config = self.config.button[joystick]
  if not config then
    return
  end
  
  button = tostring(button)
  local input = config[button]
  if input then
    self:setControl(input, value)
  end
end

function Mapper:pressed(joystick, button)
  self:setButton(joystick, button, 1)
end

function Mapper:released(joystick, button)
  self:setButton(joystick, button, 0)
end

local function normalAxis(axis, inverted)
  if not axis then
    return 0
  end

  local result = ((axis + 1) / 2) 
  return inverted and 1 - result or result
end

function Mapper:update()
  for joystick, axes in pairs(self.config.axis) do
    for axis,input in pairs(axes) do
      local value = joystick:getAxis(axis)
      self.controller:set(input.action, normalAxis(value, input.invert))
    end
  end
end

return Mapper
