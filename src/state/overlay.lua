local State = require('vendor.state')

local Mapper = require('mapper')
local Controller = require('controller')

local Resource = require('resource')
local Config = require('config_store')
local Display = require('display')
local presets = require('presets')

local mapper
local controller
local user_config

local Overlay = {}
--
local function loadConfig()
  user_config = Config.load()
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
  Overlay.reload()
end

function Overlay.enter(current)
  love.graphics.setBackgroundColor(25, 25, 25, 0)

  Overlay.reload()
end

function Overlay.reload()
  loadConfig()
  initController()
  initMapper()
end

function Overlay.update(dt)
  mapper:update(dt)
  -- cap fps
  love.timer.sleep(1/30)
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
end

return Overlay
