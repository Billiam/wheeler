local configs = {
  OVERRIDE = 'keys.conf'
}

local Loader = require('vendor.loader')
local defaults = require('default_controls')

local stub_joystick = {
  stub = true,
  getButtonCount = function()
    return 0
  end, 
  getAxisCount = function()
    return 0
  end, 
  getAxis = function()
    return 0
  end,
  getAxes = function()end
}

local Mapper = {
  joystick = stub_joystick,
}
Mapper.mt = { __index = Mapper }

function Mapper.create(controller)
  local instance = {
    controller = controller,
    config = {
      buttons = {},
      axes = {}
    }
  }

  setmetatable(instance, Mapper.mt)

  return instance
end

function Mapper:setJoystick(joystick)
  self.joystick = joystick
  print(joystick:getGUID())

  local config = self:getConfig(joystick)
  self.config = self:parse(config)
end

function Mapper:loadUserConfig()
  local content = love.filesystem.read(configs.OVERRIDE)

  if not content then
    return nil
  end
  local success, config = Loader(content)
  return success and config or nil
end

function Mapper:getConfig(joystick)
  local userConfig = self:loadUserConfig()

  if userConfig then
    return userConfig
  end

  return defaults[joystick:getGUID()] or {}
end

function Mapper:parse(config)
  local rotation = config.wheel and config.wheel.range
  if rotation then
    self.controller:set('range', rotation)
  end

  local config_groups = {
    axes = {},
    buttons = {},
  }

  for action, keys in pairs(config) do
    local control_type
    local element

    local result = { action = action, invert = false}

    if keys.button then
      control_type = 'buttons'
      element = keys.button
    elseif keys.axis then
      control_type = 'axes'
      element = keys.axis
      result.invert = keys.invert
    end

    if element then
      element = tostring(element)
      if not config_groups[control_type][element] then
        config_groups[control_type][element] = {}
      end

      table.insert(config_groups[control_type][element], result)
    end
  end

  return config_groups
end

function Mapper:activate(joystick)
  if self.joystick.stub then
    self:setJoystick(joystick)
  end
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
  self:activate(joystick)
  
  if joystick ~= self.joystick then 
    return
  end
  
  button = tostring(button)

  if self.config.buttons[button] then
    self:setControls(self.config.buttons[button], value)
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
  for axis,controls in pairs(self.config.axes) do
    for index,control in ipairs(controls) do
      local value = self.joystick:getAxis(axis)

      if control.action == 'wheel' then
        self.controller:set('wheel', value)
      else
        self.controller:set(control.action, normalAxis(value, control.invert))
      end
    end
  end
end

return Mapper