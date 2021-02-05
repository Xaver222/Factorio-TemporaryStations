temp_gui = {
}

temp_gui.open = function(event)
  if temp_gui.is_open(event) then return end
  local player = game.players[event.player_index]
  
  local main_frame = temp_gui.build_ui(player.gui.center)
  
  local train = get_personal_train(event.player_index)
  if train ~= nil then
    temp_gui.build_train_set(main_frame["tempstations-personal"]["instruction-frame"]["instruction-flow"], train)
  else
    temp_gui.build_train_notset(main_frame["tempstations-personal"]["instruction-frame"]["instruction-flow"])
  end
  
  player.opened = main_frame
end

temp_gui.close = function(event)
  local frame = game.players[event.player_index].gui.center["tempstations-main-frame"]
  
  if frame ~= nil then
    frame.destroy()
  end
end

temp_gui.is_open = function(event)
  local frame = game.players[event.player_index].gui.center["tempstations-main-frame"]
  return frame and true or false
end

temp_gui.button_clicked = function(event)
  if not event.element or not temp_gui.is_open(event) then return end
  
  local main_frame = game.players[event.player_index].gui.center["tempstations-main-frame"]
  
  if event.element.name == "tempstations-button-clear" then
    set_personal_train(event.player_index, nil)  
    temp_gui.build_train_notset(main_frame["tempstations-personal"]["instruction-frame"]["instruction-flow"])
    return
  end
  
  if event.element.name == "tempstations-button-select" then
    global.player_waiting[event.player_index] = true
    temp_gui.build_train_waiting(main_frame["tempstations-personal"]["instruction-frame"]["instruction-flow"])
    return
  end
end

temp_gui.build_ui = function(parent)
  local frame, container, element
  
  local main_frame = parent.add {type="frame", style="outer_frame_without_shadow", name="tempstations-main-frame", direction="vertical"}
  main_frame.style.minimal_width = 320
  main_frame.style.margin  = 0
  main_frame.style.padding = 0
  
  frame = main_frame.add {type="frame", caption={"tempstations.frame_title_main"}, direction="vertical"}
  frame.style.horizontally_stretchable = true
  element = frame.add {type="label", caption={"tempstations.label_commands"}}
  element = frame.add {type="label", caption="/help [font=default-bold]setdefaultschedule[/font]"}
  element.style.left_margin = 20
  element = frame.add {type="label", caption="/help [font=default-bold]setpersonaltrain[/font]"}
  element.style.left_margin = 20
  element = frame.add {type="label", caption="/help [font=default-bold]tempconfig[/font]"}
  element.style.left_margin = 20
  element = frame.add {type="label", caption="[font=default-bold]Configuration has been moved to 'Mod Settings'[/font]"}
  element.style.top_margin = 10
  element.style.horizontally_stretchable = true
  element.style.horizontal_align = "center"
  
  frame = main_frame.add {type="frame", caption={"tempstations.frame_title_personal"}, name="tempstations-personal", direction="vertical"}
  frame.style.horizontally_stretchable = true
  
  local flow = frame.add {type="flow", direction="horizontal", name="instruction-frame"}
  flow.style.horizontally_stretchable = true
  flow.style.margin = 0
  flow.style.padding = 0
  flow.style.horizontal_spacing = 10
  
  element = flow.add {type="entity-preview", name="train-preview"}
  element.style.width = 60
  element.style.height = 60
  
  flow.add {type="flow", direction="vertical", name="instruction-flow"}
  
  return main_frame
end

temp_gui.build_train_set = function(parent, train)
  parent.parent["train-preview"].entity = train.front_stock
  
  parent.clear()

  parent.add {type="label", caption={"tempstations.label_instruction_1", "", ""}}
  parent.add {type="label", caption={"tempstations.label_instruction_2", "", ""}}
  parent.add {type="label", caption={"tempstations.label_instruction_3", "[font=default-bold]", "[/font]"}}
  
  local flow = parent.add {type="flow", direction="vertical"}
  flow.style.horizontally_stretchable = true
  flow.style.margin = 0
  flow.style.padding = 0
  flow.style.top_margin = 15
  flow.style.horizontal_align="right"
  
  local element = flow.add {type="button", name="tempstations-button-clear", caption={"tempstations.button_clear"}, style="map_generator_preview_button"}
  element.style.font = "default-bold"
  element.style.width = 162
end

temp_gui.build_train_notset = function(parent)
  parent.clear()

  parent.add {type="label", caption={"tempstations.label_instruction_1", "[font=default-bold]", "[/font]"}}
  parent.add {type="label", caption={"tempstations.label_instruction_2", "", ""}}
  parent.add {type="label", caption={"tempstations.label_instruction_3", "", ""}}
  
  local flow = parent.add {type="flow", direction="vertical"}
  flow.style.horizontally_stretchable = true
  flow.style.margin = 0
  flow.style.padding = 0
  flow.style.top_margin = 15
  flow.style.horizontal_align="right"
  
  local element = flow.add {type="button", name="tempstations-button-select", caption={"tempstations.button_select"}, style="map_generator_preview_button"}
  element.style.font = "default-bold"
  element.style.width = 162
end

temp_gui.build_train_waiting = function(parent)
  parent.clear()

  parent.add {type="label", caption={"tempstations.label_instruction_1", "", ""}}
  parent.add {type="label", caption={"tempstations.label_instruction_2", "[font=default-bold]", "[/font]"}}
  parent.add {type="label", caption={"tempstations.label_instruction_3", "", ""}}
  
  local flow = parent.add {type="flow", direction="vertical"}
  flow.style.horizontally_stretchable = true
  flow.style.margin = 0
  flow.style.padding = 0
  flow.style.top_margin = 15
  flow.style.horizontal_align="right"
   
  local element = flow.add {type="button", name="tempstations-button-waiting", caption={"tempstations.button_waiting"}, style="map_generator_preview_button"}
  element.style.font = "default-bold"
  element.style.width = 162
  element.enabled = false
end

script.on_event({defines.events.on_gui_click}, temp_gui.button_clicked)

return temp_gui