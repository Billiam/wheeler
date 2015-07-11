local Smallfolk = require('vendor.smallfolk')

local Config = {}

local conf
local default = { settings = { rotation = 500 }, controls = {} }

function Config.load(force)
  if not conf or force then
    local config = love.filesystem.read('config')
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
  conf = config
  
  love.filesystem.write('config', Smallfolk.dumps(config))
end

return Config
