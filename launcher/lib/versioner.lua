-- fetch an array of numbers given a semantic version
local Versioner = {
  update_frequency = 60*60*24
}

local from_semantic = function(version_string)
  local t = {}
  for num in string.gmatch(version_string, "(%d+)") do
    table.insert(t, num)
  end
  return t
end

-- fetch (and cache) version information from disk
local current_version_data
local load = function()
  if not current_version_data then
    local default =  { version = 'v0.0.0', last_update = 0 }
    local version_data = love.filesystem.load('VERSION')

    local version = version_data and version_data() or default
    version.parsed = from_semantic(version.version)
    current_version_data = version
  end

  return current_version_data
end

local save = function(version)
  local result = love.filesystem.write('VERSION', string.format('return {version=%q, last_update=%d}', version, os.time()))
  current_version_data = nil

  return result
end

local needs_update_check = function()
  return os.time() > (load().last_update or 0 ) + Versioner.update_frequency
end

local is_newer = function(new_version, old_version)
  if type(new_version) == 'string' then
    new_version = from_semantic(new_version)
  end
  if type(old_version) == 'string' then
    old_version = from_semantic(old_version)
  end

  for i,v in ipairs(new_version) do
    local old_version_value = old_version[i]

    if v and (not old_version_value or v > old_version_value) then
      return true
    end
  end

  return false
end

local needs_download = function(new_version)
  return is_newer(new_version, load().parsed)
end

Versioner.from_semantic = from_semantic
Versioner.load = load
Versioner.save = save
Versioner.needs_update_check = needs_update_check
Versioner.is_newer = is_newer
Versioner.needs_download = needs_download


return Versioner