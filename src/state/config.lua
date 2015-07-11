local State = require('vendor.state')

local Wizard = require('wizard')
local Resource = require('resource')
local Store = require('config_store')

local previous
local wizard

local Config = {}

function Config.init()
end

function Config.enter(_, previous_state)
--  State.enter()
  
  previous = previous_state
  wizard = Wizard.new()

  wizard.config = Store.load()
end

function Config.update(dt)
  wizard:update(dt)
end

function Config.joystickpressed(joystick, button)
  wizard:joystickpressed(joystick, button)
end

function Config.joystickreleased(joystick, button)
end

function Config.keypressed(key)
  if key == 'return' then
    if not wizard:next() then
      Store.save(wizard.config)
      State.pop()
    end
  elseif key == 'delete' then
    wizard:clear()
  elseif key == 'escape' then
    State.pop()
  end
end

function Config.draw()
  previous.draw()
  love.graphics.setColor(0, 0, 0, 240)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  wizard:draw()
end

return Config
