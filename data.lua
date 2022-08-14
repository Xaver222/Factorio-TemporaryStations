local temp_shortcut = {
  type = "shortcut",
  name = "shortcut-temporarystations",
  action = "lua",
  localised_name = {"tempstations.shortcut_name"},
  toggleable = true,
  icon = {
    filename = "__TemporaryStations_X_c__/graphics/icons/shortcut.png",
    priority = "extra-high-no-scale",
    size = 32,
    scale = 2,
    flags = {"icon"}
  },
  small_icon = {
    filename = "__TemporaryStations_X_c__/graphics/icons/shortcut.png",
    priority = "extra-high-no-scale",
    size = 24,
    scale = 1,
    flags = {"icon"}
  },
  disabled_small_icon = {
    filename = "__TemporaryStations_X_c__/graphics/icons/shortcut.png",
    priority = "extra-high-no-scale",
    size = 24,
    scale = 1,
    flags = {"icon"}
  },
}

local temp_sprite = {
  type = "sprite",
  name = "tempstations-icon",
  filename = "__TemporaryStations_X_c__/graphics/icons/shortcut.png",
  width = 32,
  height = 32,
--  flags = {"gui"},
}

local temp_input_call = {
  type = "custom-input",
  name = "temp-call-a-train",
  key_sequence = "",
  consuming = "game-only"
}

local temp_input_open = {
  type = "custom-input",
  name = "temp-open-schedule",
  key_sequence = "",
  consuming = "game-only"
}

local temp_input_locate = {
  type = "custom-input",
  name = "temp-locate",
  key_sequence = "",
  consuming = "game-only"
}

data:extend({temp_shortcut, temp_sprite, temp_input_call, temp_input_open, temp_input_locate})
