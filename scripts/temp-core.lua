global.personal_train     = global.personal_train or {{}, {}}
global.player_waiting     = global.player_waiting or {}
global.blacklisted_trains = global.blacklisted_trains or {}
global.config = global.config or {
  switch_to_manual = false,
  apply_custom_conditions = true,
  
  remove_all = true,
  
  default_conditions = {{type="inactivity", compare_type="and", ticks=300}},
  
  search_radius = 20,
  render_target = true,
}
local shortcut_name = "shortcut-temporarystations"

--[[ ----------------------------------------------------------------------------------
        UTILITIES
--]] 
function get_personal_train(player_index)
  if not global.personal_train[player_index] then return nil end
  local surface_id = game.players[player_index].surface_index
  if not global.personal_train[player_index][surface_id] then return nil end
  local surface_name = game.players[player_index].surface.name:gsub("^%l", string.upper)
  
  local train = global.personal_train[player_index][surface_id]
  if not train or not train.valid then
    _print({"notifications.personal-train-not-found", surface_name}, player_index)
    global.personal_train[player_index][surface_id] = nil
    return nil
  end

  return train
end

function set_personal_train(player_index, entity)
  local surface_id = game.players[player_index].surface_index
  local surface_name = game.players[player_index].surface.name:gsub("^%l", string.upper)
  
  -- reset personal train
  if not entity then
    _print({"notifications.clearing-personal-train", surface_name}, player_index)
    global.personal_train[player_index][surface_id] = nil
    return
  end
  
  -- wrong or invalid entity
  if not entity.train or not entity.train.valid then
    return
  end
  
  -- set personal train
  _print({"notifications.setting-personal-train", surface_name, entity.train.id}, player_index)
  global.personal_train[player_index][surface_id] = entity.train
end

function set_default_schedule(entity)
  if not entity or not entity.train then return end
  
  local schedule = entity.train.schedule
  if not schedule or not schedule.records[1] then return end
  
  global.config.default_conditions = schedule.records[1].wait_conditions
  _print({"notifications.copied-schedule"})
end

local train_state_strings = {
  [defines.train_state.on_the_path]         = "ON_THE_PATH",
  [defines.train_state.path_lost]           = "PATH_LOST",
  [defines.train_state.no_schedule]         = "NO_SCHEDULE",
  [defines.train_state.no_path]             = "NO_PATH",
  [defines.train_state.arrive_signal]       = "ARRIVE_SIGNAL",
  [defines.train_state.wait_signal]         = "WAIT_SIGNAL",
  [defines.train_state.arrive_station]      = "ARRIVE_STATION",
  [defines.train_state.wait_station]        = "WAIT_STATION",
  [defines.train_state.manual_control_stop] = "MANUAL_CONTROL_STOP",
  [defines.train_state.manual_control]      = "MANUAL_CONTROL",
}

function print_train_state(new_state, old_state)
  local message = "TrainState: "
  
  if new_state ~= nil and train_state_strings[new_state] then
    message = message .. train_state_strings[new_state]
  end
  
  if old_state ~= nil and train_state_strings[old_state] then
    message = message .. " (previous: " .. train_state_strings[old_state] .. ")"
  end

  _print(message)
end

function get_personal_front_mover(player_index)
  local train = get_personal_train(player_index)
  if not train then return nil end
  
  return global.personal_train[player_index].locomotives["front_movers"][1]
end

--[[ ----------------------------------------------------------------------------------
        CORE
--]] 
local temp_core = {
  gui = require "temp-gui"
}

-- temp_core.shortcut_toggled 
--
temp_core.shortcut_toggled = function(event)
  if not event.prototype_name or event.prototype_name ~= shortcut_name then return end
 
  local player     = game.players[event.player_index]
  local is_toggled = player.is_shortcut_toggled(shortcut_name)
  
  local train = get_personal_train(event.player_index)
  -- check whether this player has set a personal train
  if train ~= nil then

    -- call the train
    if is_toggled == false then
      temp_core.call_personal_train(event, train)

    -- stop the train dead in the tracks
    else
      temp_core.stop_personal_train(event, train)
    end
    return
  end
  
  -- toggle configuration gui
  if temp_gui.is_open(event) == false then
    temp_core.gui.open(event)
    player.set_shortcut_toggled(shortcut_name, true)
  else
    temp_core.gui.close(event)
    player.set_shortcut_toggled(shortcut_name, false)
  end
end

-- temp_core.on_gui_opened 
--
temp_core.on_gui_opened = function(event)
  if not event.entity or not global.player_waiting[event.player_index] then return end
  
  if event.entity.train ~= nil then
    set_personal_train(event.player_index, event.entity)
    game.players[event.player_index].opened = nil
  end
  global.player_waiting[event.player_index] = nil
end

-- temp_core.configuration_closed 
--
temp_core.configuration_closed = function(event)
  if not event.element or event.element.name ~= "tempstations-main-frame" then return end
  
  temp_core.gui.close(event)
  game.players[event.player_index].set_shortcut_toggled(shortcut_name, false)
end

-- temp_core.call_personal_train 
--
temp_core.call_personal_train = function(event, train)
  local player = game.players[event.player_index]
  
  -- find closest rail segment
  local radius = global.config.search_radius
  local rails = player.surface.find_entities_filtered {position=player.character.position, radius=radius, type={"straight-rail", "curved-rail"}, force=player.force}
  
  if #rails == 0 then
    return
  end
  
  local closest  = player.surface.get_closest(player.character.position, rails)

  -- modify schedule and call the train
  local schedule = train.schedule
  if not schedule then
    schedule = {
      current = 1,
      records = {}
    }
  end

  table.insert(schedule.records, schedule.current, {station=nil, rail=closest, wait_conditions=global.config.default_conditions, temporary=true})
  train.schedule = schedule
  train.manual_mode = false
  
  -- draw 
  if global.config.render_target == true then
    rendering.draw_circle{color={r=0.20,b=0.73,g=0.73,a=0.5}, radius=0.3, width=3, filled=false, target=closest, surface=closest.surface, time_to_live=140, forces={player.force}, players={player}}
    rendering.draw_circle{color={r=0.20,b=0.73,g=0.73,a=0.3}, radius=0.6, width=5, filled=false, target=closest, surface=closest.surface, time_to_live=80, forces={player.force}, players={player}}
  end

  player.set_shortcut_toggled(shortcut_name, true)
end

-- temp_core.stop_personal_train 
--
temp_core.stop_personal_train = function(event, train)
  local player = game.players[event.player_index]

  train.manual_mode = true
  --_print("Stopping your train", event.player_index)
  player.set_shortcut_toggled(shortcut_name, false)
end

-- temp_core.train_state_changed 
--
temp_core.train_state_changed = function(event)
  if global.blacklisted_trains[event.train.id] then
    return
  end

  -- check if modify temp-station apply only for personal-train
  if global.config.personal_train_only == true then
    local is_personal_train = false
    for _, train in pairs(global.personal_train) do
      if train == event.train then
        is_personal_train = true
      end
    end
    if is_personal_train == false then
      return
    end
  end
  
  -- check for temporary stations and modify the wait condition  
  if global.config.apply_custom_conditions and event.train.state == defines.train_state.arrive_station then 
    local schedule = event.train.schedule
    if not event.train.schedule or not event.train.schedule.records then return end
    
    if schedule.records[schedule.current].temporary == true then
      schedule.records[schedule.current].wait_conditions = global.config.default_conditions
      event.train.schedule = schedule
    end
  end
  
  if event.train.state ~= defines.train_state.wait_station then return end
  
  -- check if the stop is temporary
  local schedule = event.train.schedule
  if not schedule or not schedule.records[schedule.current].temporary then
    return
  end
  
  -- check if there is something to do
  if global.config.switch_to_manual == true then
    event.train.manual_mode = true
  end
  
  if global.config.remove_all then
    local schedule = event.train.schedule
    for i, record in pairs(schedule.records) do 
      if record.temporary == true and not (global.config.apply_custom_conditions and i == schedule.current) then
        schedule.records[i] = nil
      end
    end
    
    schedule.current = 1
    event.train.schedule = (#schedule.records > 0 and schedule or nil)
  end
  
  -- check if train is a personal train
  for index, train in pairs(global.personal_train) do
    if train == event.train then
      game.players[index].set_shortcut_toggled(shortcut_name, false)
    end
  end
end

temp_core.player_driving_state_changed = function(event)
  if not global.config.openschedule or game.players[event.player_index].driving == false then return end 
  if not event.entity or not event.entity.train then return end
  
  if event.entity.train == get_personal_train(event.player_index) then
    temp_core.on_open_schedule(event)
  end
end

temp_core.on_open_schedule = function(event)
  local loco = get_personal_front_mover(event.player_index)
  if not loco then return end
  
  game.players[event.player_index].opened = loco
end

temp_core.locate_personal_train = function(event)
  local loco = get_personal_front_mover(event.player_index)
  if not loco then return end
  
  game.players[event.player_index].zoom_to_world(loco.position, 0.5)
end

--[[ ----------------------------------------------------------------------------------
        EVENTS
--]] 
script.on_event({defines.events.on_lua_shortcut}, temp_core.shortcut_toggled)
script.on_event({defines.events.on_gui_closed}, temp_core.configuration_closed)
script.on_event({defines.events.on_gui_opened}, temp_core.on_gui_opened)
script.on_event({defines.events.on_train_changed_state}, temp_core.train_state_changed)
script.on_event({defines.events.on_player_driving_changed_state}, temp_core.player_driving_state_changed)
script.on_event("temp-call-a-train", function(event)
  event.prototype_name = shortcut_name
  temp_core.shortcut_toggled(event) 
end)
script.on_event("temp-open-schedule", temp_core.on_open_schedule)
script.on_event("temp-locate", temp_core.locate_personal_train)

return temp_core