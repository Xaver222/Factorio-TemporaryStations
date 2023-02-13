local tsx_core = require "scripts.tsx-core"

global.version4 = true
global.version_ltn = true


--[[ ----------------------------------------------------------------------------------
        UTILITY
--]]
function _print(message, player_index)
  if type(message) == "table" then
    table.insert(message, 2, "[img=tsx-icon]")
    -- message[3] = message[2]
    -- message[2] = "[img=tsx-icon]"
  else
    message = "[img=tsx-icon] " .. message
  end
  
  if player_index ~= nil then
    game.players[player_index].print(message)
  else
    game.print(message)
  end
end

--[[ ----------------------------------------------------------------------------------
        COMMANDS
--]]
local function command_set_personal_train(event)
  set_personal_train(event.player_index, game.players[event.player_index].selected)
end
commands.add_command("tsx-settrain", {"commands.tsx-settrain"}, command_set_personal_train)

local function command_reset_personal_train_config(event)
  reset_personal_train_config(event.player_index, game.players[event.player_index].selected)
end
commands.add_command("tsx-reset", {"commands.tsx-reset"}, command_reset_personal_train_config)

local function command_set_default_schedule(event)
  set_default_schedule(game.players[event.player_index].selected)
end
commands.add_command("tsx-setdefault", {"commands.tsx-setdefault"}, command_set_default_schedule)
commands.add_command("tsx-config", {"commands.tsx-config"}, tsx_core.gui.open)

--[[ ----------------------------------------------------------------------------------
        MOD CORE
--]]
local function mod_update_settings()
  global.config.switch_to_manual = (settings.global["tsx-behaviour"].value == "switch-to-manual" and true or false)
  global.config.apply_custom_conditions = (settings.global["tsx-behaviour"].value == "apply-custom-conditions" and true or false)
  global.config.remove_all = settings.global["tsx-removetemps"].value
  global.config.search_radius = tonumber(settings.global["tsx-searchradius"].value)
  global.config.render_target = settings.global["tsx-rendertarget"].value
  global.config.personal_train_only = settings.global["tsx-personaltrainonly"].value
  global.config.openschedule = settings.global["tsx-openschedule"].value
end
script.on_event({defines.events.on_runtime_mod_setting_changed}, mod_update_settings) 

mod_update_settings()

local function ltn_dispatcher_updated(event)
  if event.deliveries then
    for train_id, delivery in pairs(event.deliveries) do
      global.blacklisted_trains[train_id] = delivery.train
    end
  end
end

local function mod_init()
  if remote.interfaces["logistic-train-network"] then
    script.on_event(remote.call("logistic-train-network", "on_dispatcher_updated"), ltn_dispatcher_updated)
  end
end

local function mod_configuration_changed(data)
  if not global.version4 then
    _print("The mod Temporary Stations Improvements got a complete overhaul. For changes take a look at https://mods.factorio.com/mod/QoL-TempStations!")
    global.version4 = true
  end
  
  -- fix for ltn > 1.13.0 compatibility  
  --if not global.version_ltn then
    if remote.interfaces["logistic-train-network"] then
      script.on_event(remote.call("logistic-train-network", "on_dispatcher_updated"), ltn_dispatcher_updated)
      global.version_ltn = true
    end
    
  --end
end

local function mod_load(f)
  if remote.interfaces["logistic-train-network"] then
    script.on_event(remote.call("logistic-train-network", "on_dispatcher_updated"), ltn_dispatcher_updated)
  end
end

local function command_fix_dispatcher(event)
  if remote.interfaces["logistic-train-network"] then
    script.on_event(remote.call("logistic-train-network", "on_dispatcher_updated"), ltn_dispatcher_updated)
  end
end
commands.add_command("fixdispatcher", {"commands.fixdispatcher"}, command_fix_dispatcher)

--[[ ----------------------------------------------------------------------------------
        HOOK EVENTS 
--]]
script.on_init(mod_init)
--script.on_load(mod_load) 
script.on_configuration_changed(mod_configuration_changed)
