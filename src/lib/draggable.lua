local Draggable = {}

local dragging = false

function Draggable.move(dx, dy)
  if dragging then
    local start_x, start_y, display_index = love.window.getPosition()
    local display_w, display_h = love.window.getDesktopDimensions(display_index)
    local win_w, win_h = love.graphics.getDimensions()

    -- prevent window from moving > 80% out of current display
    local minimum_x = -0.8 * win_w
    local maximum_x = display_w - 0.2 * win_w

    local minimum_y = -0.8 * win_h
    local maximum_y = display_h - 0.2 * win_h

    local target_x = math.max(minimum_x, math.min(maximum_x, start_x + dx))
    local target_y = math.max(minimum_y, math.min(maximum_y, start_y + dy))

    love.window.setPosition(target_x, target_y, display_index)
  end
end

function Draggable.start(x, y)
  dragging = {x = x, y = y}
  love.mouse.setRelativeMode(true)
end

function Draggable.stop(x, y)
  love.mouse.setRelativeMode(false)

  if dragging then
    love.mouse.setPosition(dragging.x, dragging.y)
    dragging = false
  end
end

return Draggable
