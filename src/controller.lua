local Gear = {
  NEUTRAL = 'n'
}

local Controller = {
  gear = Gear.NEUTRAL,
}

Controller.mt = { __index = Controller }


function Controller.create()
  local instance = {
    data = {
      range = 540
    }
  }

  setmetatable(instance, Controller.mt)

  return instance
end

local function parseGear(control)
  local s_index, e_index, gear = string.find(control, "gear_(%w)")

  return gear
end

function Controller:setGear(gear, value)
  if value > 0 then
    self.gear = gear
  elseif gear == self.gear then
    self.gear = Gear.NEUTRAL
  end
end

function Controller:rotation()
  return self:get('wheel') * self:get('range')/2
end

function Controller:set(control, value)
  local gear = parseGear(control)
  if gear then
    self:setGear(gear, value)
  else
    self.data[control] = value
  end
end

function Controller:get(control)
  if control == 'gear' then
    return self.gear
  end 
  
  return self.data[control] or 0
end

function Controller:isOn(control)
  return self:get(control) > 0
end

return Controller