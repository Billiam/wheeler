local configs = {
  ["6d049bc2000000000000504944564944"] = {
      name = "Logitech G27 Racing Wheel USB",
      wheel = {axis = 1, range = 540},
      throttle = {axis = 2, invert = true},
      brake = {axis = 3, invert = true},
      clutch = {axis = 5, invert = true},
      handbrake = {button = 1 },
      upshift = { button = 6 },
      downshift = { button = 5 },
      gear_1 = { button = 9 },
      gear_2 = { button = 10 },
      gear_3 = { button = 11 },
      gear_4 = { button = 12 },
      gear_5 = { button = 13 },
      gear_6 = { button = 14 },
      gear_reverse = { button = 15 },
  },
  ["00000000000000000000000000000000"] = {
      name = "xinput",
      wheel = {axis = 1, range = 180},
      throttle = {axis = 6},
      brake = {axis = 5},
      handbrake = {button = 11 }
    }
}

configs['78696e70757401000000000000000000'] = configs['00000000000000000000000000000000']

return configs
