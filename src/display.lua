local Resource = require('resource')

local Display = {}

local bar_height = 80
local bar_width = 48

local offset_x = 10
local offset_y = 0

local wheel_radius = 35
local wheel_x = wheel_radius
local wheel_y = wheel_radius + bar_height + offset_y - 10

local hb_radius = 20
local hb_x = wheel_radius
local hb_y = wheel_y + wheel_radius + hb_radius + 15

local bars = {'clutch', 'brake','throttle'}
local bar_colors = {
  clutch = {20, 50, 220},
  brake = {180, 0, 0},
  throttle = {0, 180, 0}
}

local function circleHub()
  love.graphics.circle("fill", wheel_x, wheel_y, wheel_radius - 10, 30)
end

local function hbHubInner()
  love.graphics.circle("fill", hb_x, hb_y, hb_radius - 4, 30)
end

local function hbHub()
  love.graphics.circle("fill", hb_x, hb_y, hb_radius + 6, 30)
end

local function draw_handbrake(amount)
  if amount == 0 then
    return
  end

  local startPosition = -0.5*math.pi
  love.graphics.setInvertedStencil(hbHubInner)
    love.graphics.arc('fill', hb_x, hb_y, hb_radius, startPosition, startPosition + math.pi * 2 * amount, 30)
  love.graphics.setStencil()

  love.graphics.rectangle('fill', 33, hb_y - 12, 5, 15)
  love.graphics.rectangle('fill', 33, hb_y + 8, 5, 5)

  love.graphics.setInvertedStencil(hbHub)
    love.graphics.arc('fill', hb_x, hb_y, hb_radius + 10, math.rad(30), math.rad(-30))
    love.graphics.arc('fill', hb_x, hb_y, hb_radius + 10, math.rad(150), math.rad(210))
  love.graphics.setStencil()
end

local function draw_bar(amount, color, width, position)
  local pos_x = offset_x + width * (position - 1)

  local r, g, b = unpack(color)
  love.graphics.setColor(r, g, b, 60)
  love.graphics.rectangle('fill', pos_x, offset_y, width, bar_height)

  if amount == 1 then
    local bright = {}
    for i, v in ipairs(color) do
      bright[i] = math.max(v * 1.41, 255)
    end
    color = bright
  end
  local control_height = amount * bar_height

  love.graphics.setColor(r, g, b, 255)
  love.graphics.rectangle('fill', pos_x, offset_y + bar_height - control_height, width, control_height)
end

local function isHidden(control, settings)
  return settings[control] and settings[control].hide
end

local function rotation(range, controller) 
  range = range or 540
  return range * controller:get('wheel') - range/2
end

function Display.render(controller, settings)
  love.graphics.setInvertedStencil(circleHub)
    local visible_bars = {}
    for i,control in ipairs(bars) do
      if not isHidden(control, settings) then
        table.insert(visible_bars, control)
      end
    end

    local bar_count = #visible_bars
    local display_width = bar_width/bar_count
    
    for i,control in ipairs(visible_bars) do
      draw_bar(controller:get(control), bar_colors[control], display_width, i)
    end

    local rot = rotation(settings.rotation, controller)
    love.graphics.setColor(50, 50, 50, 255)
    love.graphics.circle("fill", wheel_x, wheel_y, wheel_radius)
    
    love.graphics.setColor(222, 212, 20, 255)

    love.graphics.arc( "fill", wheel_x, wheel_y, wheel_radius, math.rad(rot - 10 - 90), math.rad(rot + 10 - 90))
  love.graphics.setStencil()
  
  love.graphics.setFont(Resource.font.seven_segment[50])
  love.graphics.setColor(0, 0, 0, 50)
  love.graphics.print('8', 22, wheel_y - 23)
  love.graphics.setColor(255, 200, 255, 255)
  love.graphics.print(controller:get('gear'), 22, wheel_y - 23)

  -- handbrake
  love.graphics.setColor(0, 0, 0, 50)
  draw_handbrake(1)

  love.graphics.setColor(255, 127, 0, 255)
  draw_handbrake(controller:get('handbrake'))
end

return Display
