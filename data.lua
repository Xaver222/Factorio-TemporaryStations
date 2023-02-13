local tsx_shortcut = {
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

local tsx_sprite = {
  type = "sprite",
  name = "tsx-icon",
  filename = "__TemporaryStations_X_c__/graphics/icons/shortcut.png",
  width = 32,
  height = 32,
--  flags = {"gui"},
}

local tsx_input_call = {
  type = "custom-input",
  name = "tsx-call-a-train",
  key_sequence = "",
  consuming = "game-only"
}

local tsx_input_open = {
  type = "custom-input",
  name = "tsx-open-schedule",
  key_sequence = "",
  consuming = "game-only"
}

local tsx_input_locate = {
  type = "custom-input",
  name = "tsx-locate",
  key_sequence = "",
  consuming = "game-only"
}

data:extend({tsx_shortcut, tsx_sprite, tsx_input_call, tsx_input_open, tsx_input_locate})
