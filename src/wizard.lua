local String = require('lib.string')

local CONTROLS = {
  wheel = 'Turn wheel to lock',
  wheel_rotation = 'Hold wheel at 90 degrees',
  throttle = 'Press throttle pedal',
  brake = 'Press brake pedal',
  clutch = 'Press clutch pedal',
  handbrake = 'Press handbrake',
  upshift = 'Shift up',
  downshift = 'Shift down',
  gear_1 = '1st gear',
  gear_2 = '2nd gear',
  gear_3 = '3rd gear',
  gear_4 = '4th gear',
  gear_5 = '5th gear',
  gear_6 = '6th gear',
  gear_7 = '7th gear',
  gear_reverse = 'Reverse gear',
}

local STAGES = {
  'wheel',
  'wheel_rotation',
  'throttle',
  'brake',
  'clutch',
  'handbrake',
  'upshift',
  'downshift',
  'gear_1',
  'gear_2',
  'gear_3',
  'gear_4',
  'gear_5',
  'gear_6',
  'gear_7',
  'gear_reverse',
}

local AXES = {
  ['1'] = 'X',
  ['2'] = 'Y',
  ['3'] = 'Z',
}

local function getJoystick(id)
  for _,v in ipairs(love.joystick.getJoysticks()) do
    if v:getGUID() == id then
      return v
    end
  end
end

local font = love.graphics.newFont(11)

local Wizard = {}
Wizard.mt = { __index = Wizard }

Wizard.new = function()
  local instance = {
    stage = 1,
    config = {
      controls = {},
      settings = {
        rotation = 500
      },
    },
  }
  
  setmetatable(instance, Wizard.mt)

  instance:cacheDefaults()

  return instance
end


local function anyActive(list, config)
  for _, key in ipairs(list) do
    if config.controls[key] then
      return true
    end
  end

  return false
end

local function input_description(input)
  local invert = input.invert and "- " or ""
  local axis = AXES[input.input]
  if input.type == 'axis' and axis then
    return invert  .. axis .. " axis"
  else
    return invert .. input.type .. " " .. input.input
  end
end

function Wizard:getAxes()
  local axes = {}

  local joysticks = love.joystick.getJoysticks()
  for _, joystick in ipairs(joysticks) do
    axes[joystick:getGUID()] = { joystick:getAxes() }
  end

  return axes
end

function Wizard:cacheDefaults()
  self.defaults = self:getAxes()
end

function Wizard:joystickconnected(joystick)
  self:cacheDefaults()
end

function Wizard:joystickpressed(joystick, button)
  local input = { type = 'button', input = tostring(button), joystick = joystick:getGUID(), invert = false }
  self:setInput(input)
end

function Wizard:removeDuplicates()
  local input = self:getInput()
  if not input then return end
  for key, other in pairs(self.config.controls) do
    
    if other ~= input and other.joystick == input.joystick and other.input == input.input and other.type == input.type then
      self.config.controls[key] = nil
    end
  end
end

function Wizard:updateHidden()
  local key = self:currentStage()
  if not self.config.controls[key] then
    self.config.settings[key] = self.config.settings[key] or {}
    self.config.settings[key].hide = true
  else
    self.config.settings[key] = nil
  end
end

function Wizard:next()
  self:removeDuplicates()
  if self.stage < #STAGES then 
    self.stage = self.stage + 1
    return true
  else
    return false
  end
end

function Wizard:setConfig(config)
  self.config = config
end

function Wizard:getConfig()
  local config = self.config
  
  local hidden = { 'throttle', 'brake', 'clutch', 'handbrake' }
  for _,key in ipairs(hidden) do
    local exists = config.controls[key]
    if exists then
      config.settings[key] = nil
    else
      config.settings[key] = { hide = true }
    end
  end
  
  if anyActive({'upshift', 'downshift'}, config) then
    config.settings.sequential = nil
  else
    config.settings.sequential = { hide = true }
  end
  
  local gears = { 'gear_1', 'gear_2', 'gear_3', 'gear_4', 'gear_5', 'gear_6', 'gear_7', 'gear_reverse' }
  if anyActive(gears, config) then
    config.settings.gears = nil
  else
    config.settings.gears = { hide = true }
  end
  
  config.default = nil
  
  return config
end

function Wizard:getActive()
  local current = self:getAxes()
  
  for id, axes in pairs(current) do
    local defaults = self.defaults[id]
    if defaults then
      for index, axis in ipairs(axes) do
        local difference = axis - defaults[index]
        if math.abs(difference) > 0.45 then
          return { type = 'axis', input = tostring(index), joystick = id, invert = difference < 0 }
        end
      end
    end
  end
end

function Wizard:update()
  if self.stage == 2 then
    self:update_rotation()
  else
    local input = self:getActive()
    
    if input then
      self:setInput(input)
    end
  end
end

function Wizard:update_rotation()
  local input = self.config.controls.wheel
  if not input then return end
  
  local joystick = getJoystick(input.joystick)
  if not joystick or input.type ~= 'axis' then
    self:next()
    return
  end
  
  local value = math.abs(joystick:getAxis(input.input))
  if value > 0.05 then
    self.config.settings.rotation = math.floor((180/value)/5) * 5
  end
end

function Wizard:currentStage()
  return STAGES[self.stage]
end

function Wizard:setInput(input)
  if self.stage == 1 then
    input.invert = false
  end
  
  self.config.controls[self:currentStage()] = input
end

function Wizard:getInput()
  return self.config.controls[self:currentStage()]
end

function Wizard:clear()
  self.config.controls[self:currentStage()] = nil
end

function Wizard:draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font)
  love.graphics.printf(CONTROLS[self:currentStage()], 5, 5, w - 10)
  
  love.graphics.printf("Enter to continue", 5, h - 30, w - 10)

  -- display current rotation
  if self.stage == 2 then
    love.graphics.print(self.config.settings.rotation .. '°', 5, 120)
  else
    local current = self.config.controls[self:currentStage()]
    if current then
      local joystick = getJoystick(current.joystick)
      local name = joystick and String.truncate_lines(joystick:getName(), 2, w-10) or "unknown"
      
      love.graphics.setColor(90, 90, 90, 255)
      love.graphics.printf(name, 5, 80, w - 10)
      
      love.graphics.setColor(255, 255, 255, 255)
      love.graphics.print(input_description(current), 5, 120)
    end
  end
end

return Wizard
