local CONTROLS = {
  wheel = 'Turn wheel to lock',
  wheel_rotation = 'Hold wheel at 90 degrees',
  throttle = 'Press throttle pedal',
  brake = 'Press brake pedal',
  clutch = 'Press clutch pedal',
  handbrake = 'Press handbrake',
  upshift = 'Shift up',
  downshift = 'Shift down',
  gear_1 = 'First gear',
  gear_2 = 'Second gear',
  gear_3 = 'Third gear',
  gear_4 = 'Fourth gear',
  gear_5 = 'Fifth gear',
  gear_6 = 'Sixth gear',
  gear_7 = 'Seventh gear',
  gear_reverse = 'Reverse',
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

local function getJoystick(id)
  for i,v in ipairs(love.joystick.getJoysticks()) do
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

function Wizard:getAxes()
  local axes = {}

  local joysticks = love.joystick.getJoysticks()
  for i, joystick in ipairs(joysticks) do
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
    
    if other ~= input and other.joystick == input.joystick and other.input == input.input and other.type == other.type then
      self.config.controls[key] = nil
    end
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

function Wizard:getActive()
  local current = self:getAxes()
  
  for id, axes in pairs(current) do
    local defaults = self.defaults[id]

    for index, axis in ipairs(axes) do
      local difference = axis - defaults[index]
      if math.abs(difference) > 0.45 then
        return { type = 'axis', input = tostring(index), joystick = id, invert = difference < 0 }
      end
    end
  end
end

function Wizard:update(dt)
--  if self.active_input then
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
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(font)
  love.graphics.printf(CONTROLS[self:currentStage()], 10, 10, love.graphics.getWidth() - 20)
  
  love.graphics.printf("Enter to continue", 10, love.graphics.getHeight() - 40, love.graphics.getWidth() - 20)

  -- display current rotation
  if self.stage == 2 then
    love.graphics.print(self.config.settings.rotation .. '°', 10, 100)
  else
    local current = self.config.controls[self:currentStage()]
    if current then
      love.graphics.print((current.invert and "-" or "") .. current.type .. " " .. current.input, 10, 100)
    end
  end
end

return Wizard
