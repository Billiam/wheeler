require('vendor.background_joystick')

local JoyDebug = require('joy_debug')

local Mapper = require('mapper')
local Controller = require('controller')
local Display = require('display')

local mapper
local controller
local debugger
local debug_joystick = false

local function generateExample()
  local example_name = 'keys.conf.example'

  if not love.filesystem.isFile(example_name) then
    local example = require('example')
    love.filesystem.write(example_name, example)
  end

  local readme_name = 'README'
  if not love.filesystem.isFile(readme_name) then
    love.filesystem.write(readme_name, love.filesystem.read('config_readme.txt'))
  end
end

local function initMapper()
  controller = Controller.create()
  mapper = Mapper.create(controller)
end

local function init(arg)
  for i,argument in ipairs(arg) do
    if argument == '--debug' then
      io.stdout:setvbuf("no")
      
      local inspect = require('vendor.inspect')
      _G.dump = function(...) print(inspect(...)) end
    end
  end

  debugger = JoyDebug.create()
end

function love.load(arg)
  init(arg)
  generateExample()
  initMapper()

  love.graphics.setBackgroundColor(0, 0, 0, 0)
end

function love.update()
  -- cap FPS for performance when recording
  love.timer.sleep(1/30)
  mapper:update()
end

function love.draw()
  if debug_joystick then
    debugger:show(mapper.joystick)
    return
  end

  Display.render(controller)
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if key == 'z' then
    debug_joystick = not debug_joystick
  end
end

function love.joystickreleased(joystick, button)
  debugger:setJoystick(joystick)
  mapper:released(joystick, button)
end

function love.joystickpressed(joystick, button)
  mapper:pressed(joystick, button)
end