local State = require('vendor.state')

local Mapper = require('mapper')
local Controller = require('controller')

local Resource = require('resource')
local Config = require('config_store')
local Display = require('display')

local mapper
local controller
local user_config

local default_font = love.graphics.newFont(11)

local Overlay = {}
--
local function loadConfig(force)
  user_config = Config.load(force)
end

local function initMapper()
  mapper = Mapper.create(controller, user_config.controls)
end

local function initController()
  controller = Controller.create()
end

function Overlay.init()
end

function Overlay.resume()
  Overlay.reload(true)
end

function Overlay.enter()
  love.graphics.setBackgroundColor(25, 25, 25, 0)

  Overlay.reload()
end

function Overlay.reload(force)
  loadConfig(force)
  initController()
  initMapper()
end

function Overlay.update(dt)
  mapper:update(dt)
  -- cap fps
  Display.update(dt)
end

function Overlay.joystickpressed(joystick, button)
  mapper:pressed(joystick, button)
end

function Overlay.joystickreleased(joystick, button)
  mapper:released(joystick, button)
end

function Overlay.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'c' then
    State.push(Resource.state.config)
  end
end

function Overlay.draw() 
  Display.render(controller, user_config.settings)
  
  if user_config.default then
    love.graphics.setColor(0, 0, 0, 240)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(default_font)
    love.graphics.printf('Press C to configure', 5, 50, love.graphics.getWidth() - 10)
  end
end

return Overlay
