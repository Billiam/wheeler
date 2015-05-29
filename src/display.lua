local Resource = require('resource')

local Display = {}

local bar_height = 80
local bar_width = 25

local offset_x = 10
local offset_y = 0

local wheel_radius = 35
local wheel_x = wheel_radius
local wheel_y = wheel_radius + bar_height + offset_y - 10

local hb_radius = 20
local hb_x = wheel_radius
local hb_y = wheel_y + wheel_radius + hb_radius + 15

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

function Display.render(controller)
  love.graphics.setInvertedStencil(circleHub)

    love.graphics.setColor(200, 0, 0, 60)
    love.graphics.rectangle('fill', offset_x, offset_y, bar_width, bar_height)

    love.graphics.setColor(0, 200, 0, 60)
    love.graphics.rectangle('fill', offset_x + bar_width, offset_y, bar_width, bar_height)

    -- brake
    local braking = controller:get('brake')

    love.graphics.setColor(braking == 1 and 255 or 180, 0, 0, 255)
    local brake_height = braking * bar_height
    love.graphics.rectangle('fill', offset_x, offset_y + bar_height - brake_height, bar_width, brake_height)

    -- gas
    local throttle = controller:get('throttle')

    local throttle_height = throttle * bar_height
    love.graphics.setColor(0, throttle == 1 and 255 or 180, 0, 255)
    love.graphics.rectangle('fill', offset_x + bar_width, offset_y + bar_height - throttle_height, bar_width, throttle_height)
    
    local rot = controller:rotation()
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