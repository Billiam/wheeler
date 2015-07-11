local Smallfolk = require('vendor.smallfolk')

local Config = {}

local conf
local default = { default = true, settings = { rotation = 500 }, controls = {} }

local FILENAME = 'config'

function Config.exists()
  return love.filesystem.isFile(FILENAME)
end

function Config.load(force)
  if not conf or force then
    local config = love.filesystem.read(FILENAME)
    if not config then return default end
  
    local success, result = pcall(function() return Smallfolk.loads(config) end)
    if not success or not result then return default end
  
    result.settings = result.settings or {}
    result.controls = result.controls or {}
  
    conf = result
  end
  
  return conf
end

function Config.save(config)
  love.filesystem.write(FILENAME, Smallfolk.dumps(config))
end

return Config
