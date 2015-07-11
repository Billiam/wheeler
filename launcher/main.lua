io.stdout:setvbuf("no")

local config = require('launcher_config')

local Versioner = require('lib.versioner')
local byte_convert = require('lib.filesize')
local json = require('lib.json')

local updater =  require('vendor.love-update')

local download_speed
local download_percent
local status_message = 'Loading...'
local loaded = false

local function download_progress(_, _, percent, speed)
  download_percent = percent
  download_speed = speed
end

local function parse_update(release_json)
  local data = json.decode(release_json)

  if not (data and data.version and data.url) then
    error('Could not parse version data')
  end

  return data
end

local function precache_game()
  if not love.filesystem.isFile(config.LOVE_NAME) and love.filesystem.isFile('cache.zip') then
    love.filesystem.write(config.LOVE_NAME, love.filesystem.read('cache.zip'))
  end
end

local function save(version)
  Versioner.save(version)
end

local function handle_update(data)
  if Versioner.needs_download(data.version) then
    local promise = updater.download(data.url, config.LOVE_NAME, download_progress)
      :next(function()
        save(data.version)

        return true
      end)

    return promise
  else
    save(data.version)
  end

  return data
end

local function prepare_launch()
  loaded = true
end

function fallback(reason)
  print('Error: ', reason)
  -- update has failed, attempt to launch
  if updater.can_launch(config.LOVE_NAME) then
    prepare_launch()
  else
    status_message = 'Download failed!'
  end
end

function love.load()
  precache_game()

  if Versioner.needs_update_check() or not updater.can_launch(config.LOVE_NAME) then
    updater.fetch(config.VERSION_URL)
      :next(parse_update)
      :next(handle_update)
      :next(prepare_launch)
      :catch(print)
  else
    prepare_launch()
  end
end

function love.update(dt)
  if loaded then
    updater.launch(config.LOVE_NAME, arg)
  end

  updater.update(dt)
end

local function launch()
  endupdater.launch('invalid', arg)
end

function love.draw()
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(status_message, 20, 20)

  if download_percent then
    love.graphics.rectangle("fill", 10, 10, download_percent * 180, 30)
    love.graphics.setColor(150, 150, 180, 255)
    love.graphics.print(byte_convert(download_speed, 1) .. '/s', 130, 20)
  end
end

function love.keypressed(key)
  if key == 'esc' then
    love.event.quit()
  end
end

function love.threaderror(thread, err)
  error(err)
end
