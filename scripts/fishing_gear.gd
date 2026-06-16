extends Control

var water_zone_node: Node2D = null
var active_gears: Array = []

var bite_system: Node
var minigame_ui: Control
var retry_timer: Timer

const ROD_SPACING = 60


func _ready():
	GlobalLogger.log("=== FishingGear ready ===")
	
	bite_system = Node.new()
	bite_system.name = "BiteSystem"
	bite_system.set_script(load("res://scripts/bite_system.gd"))
	add_child(bite_system)
	
	minigame_ui = Control.new()
	minigame_ui.name = "MinigameUI"
	minigame_ui.set_script(load("res://scripts/minigame.gd"))
	minigame_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(minigame_ui)
	
	var gear_setup = Control.new()
	gear_setup.name = "СлойСнастиНастройка"
	gear_setup.set_script(load("res://scripts/gear_setup_panel.gd"))
	gear_setup.mouse_filter = Control.MOUSE_FILTER_STOP
	get_node("/root/GlobalUi/UILayer").add_child.call_deferred(gear_setup)
	
	var msg_panel = Control.new()
	msg_panel.name = "MessagePanel"
	msg_panel.set_script(load("res://scripts/message_panel.gd"))
	msg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	msg_panel.z_index = 500
	get_node("/root/GlobalUi/UILayer").add_child.call_deferred(msg_panel)
	
	retry_timer = Timer.new()
	retry_timer.one_shot = true
	retry_timer.wait_time = 0.5
	add_child(retry_timer)
	
	bite_system.bite_hooked.connect(_on_bite_hooked)
	bite_system.bite_missed.connect(_on_bite_missed)
	minigame_ui.minigame_won.connect(_on_minigame_won)
	minigame_ui.minigame_lost.connect(_on_minigame_lost)
	GameData.quick_slots_changed.connect(_on_quick_slots_changed)
	
	visible = true


func _process(_delta):
	for gear in active_gears:
		if not gear or typeof(gear) != TYPE_DICTIONARY:
			continue
		if gear.get("float") and gear.get("line") and gear.get("rod"):
			_update_line(gear)


func set_water_zone(zone: Node2D):
	water_zone_node = zone


func on_quick_slot_pressed(slot_index: int):
	if not GameData.is_slot_ready(slot_index):
		return
	
	var existing = _find_gear_by_slot(slot_index)
	if existing != null:
		if existing.get("in_minigame"):
			return
		_remove_gear(existing)
	else:
		_add_gear(slot_index)


func remove_gear_by_slot(slot_index: int):
	var gear = _find_gear_by_slot(slot_index)
	if gear != null:
		_remove_gear(gear)


func _on_quick_slots_changed():
	var quick_slots_bar = get_node_or_null("/root/GlobalUi/UILayer/QuickSlotsBar")
	if quick_slots_bar and quick_slots_bar.has_method("refresh_buttons"):
		quick_slots_bar.refresh_buttons()


func _find_gear_by_slot(slot_index: int):
	for gear in active_gears:
		if gear and typeof(gear) == TYPE_DICTIONARY and gear.get("slot") == slot_index:
			return gear
	return null


func _add_gear(slot_index: int):
	var screen_size = get_viewport_rect().size
	var base_x = screen_size.x / 2
	
	var rod_x
	match slot_index:
		0: rod_x = base_x - ROD_SPACING
		1: rod_x = base_x
		2: rod_x = base_x + ROD_SPACING
		_: rod_x = base_x
	
	var rod = ColorRect.new()
	rod.name = "RodDisplay_slot" + str(slot_index)
	rod.color = Color(0.3, 0.3, 0.3, 0.9)
	rod.size = Vector2(20, 300)
	rod.position = Vector2(rod_x - 10, screen_size.y - 310)
	rod.mouse_filter = Control.MOUSE_FILTER_STOP
	rod.gui_input.connect(_on_rod_clicked.bind(slot_index))
	rod.z_index = -1
	add_child(rod)
	move_child(rod, 0)
	
	var label = Label.new()
	label.name = "RodLabel_slot" + str(slot_index)
	label.text = str(slot_index + 1)
	label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0, 0.8))
	label.add_theme_font_size_override("font_size", 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = Vector2(26, 26)
	label.position = Vector2(rod_x - 13, screen_size.y - 90)
	add_child(label)
	
	var flt = ColorRect.new()
	flt.name = "FloatDisplay_slot" + str(slot_index)
	flt.color = Color(1.0, 0.0 + slot_index * 0.2, 0.0 + slot_index * 0.2, 1)
	flt.size = Vector2(16, 16)
	flt.position = Vector2(rod_x - 8, screen_size.y - 160)
	add_child(flt)
	
	var line = Line2D.new()
	line.name = "LineDisplay_slot" + str(slot_index)
	line.width = 2
	line.default_color = Color(1.0, 1.0, 1.0, 0.8)
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2.ZERO)
	add_child(line)
	
	var gear = {
		"slot": slot_index,
		"rod": rod,
		"float": flt,
		"line": line,
		"label": label,
		"is_active": false,
		"current_fish": null,
		"is_biting": false,
		"float_original_pos": flt.position,
		"in_minigame": false,
		"last_cast_pos": null
	}
	active_gears.append(gear)
	_set_active_gear(gear)


func _on_rod_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var gear = _find_gear_by_slot(slot_index)
		if gear != null:
			_set_active_gear(gear)


func _remove_gear(gear):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	bite_system.stop_bite_timer(gear)
	minigame_ui.cleanup(gear)
	active_gears.erase(gear)
	for key in ["rod", "float", "line", "label"]:
		var node = gear.get(key)
		if node and is_instance_valid(node):
			node.queue_free()


func _set_active_gear(gear):
	if not gear or typeof(gear) != TYPE_DICTIONARY:
		return
	for g in active_gears:
		if not g or typeof(g) != TYPE_DICTIONARY:
			continue
		g["is_active"] = (g == gear)
		var rod = g.get("rod")
		if rod and is_instance_valid(rod):
			rod.color = Color(1.0, 0.3, 0.3, 1.0) if g["is_active"] else Color(0.3, 0.3, 0.3, 0.9)
		if g["is_active"]:
			minigame_ui.set_active_slot(g.get("slot", -1))


func _get_active_gear():
	for gear in active_gears:
		if gear and typeof(gear) == TYPE_DICTIONARY and gear.get("is_active"):
			return gear
	return null


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			var file_name = "user://save_%s.json" % GameData.current_player_name
			DirAccess.remove_absolute(file_name)
			DirAccess.remove_absolute("user://current_user.json")
			get_tree().reload_current_scene()
			return
		
		var slot_index = -1
		if event.keycode >= KEY_1 and event.keycode <= KEY_3:
			slot_index = event.keycode - KEY_1
		elif event.keycode >= KEY_KP_1 and event.keycode <= KEY_KP_3:
			slot_index = event.keycode - KEY_KP_1
		
		if slot_index >= 0:
			var gear = _find_gear_by_slot(slot_index)
			if gear != null:
				_set_active_gear(gear)
			return
		
		if event.keycode == KEY_SPACE:
			_try_hook()
			return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_any_window_open():
			return
		var active_gear = _get_active_gear()
		if not active_gear:
			return
		var quick_slots_bar = get_node_or_null("/root/GlobalUi/UILayer/QuickSlotsBar")
		if _is_click_on_water(event.position) and not _is_click_on_rod(event.position):
			if not quick_slots_bar or not _is_click_on_quick_buttons(event.position, quick_slots_bar):
				_cast_float(active_gear, event.position)


func _is_any_window_open() -> bool:
	var inv = get_node_or_null("/root/GlobalUi/UILayer/СлойИнвентаря")
	var map_panel = get_node_or_null("/root/GlobalUi/UILayer/СлойКарты")
	var gear_setup = get_node_or_null("/root/GlobalUi/UILayer/СлойСнастиНастройка")
	var cage_panel = get_node_or_null("/root/GlobalUi/UILayer/CagePanel")
	return (inv and inv.visible) or (map_panel and map_panel.visible) or (gear_setup and gear_setup.visible) or (cage_panel and cage_panel.visible)


func _is_click_on_rod(pos: Vector2) -> bool:
	for gear in active_gears:
		var rod = gear.get("rod")
		if rod and is_instance_valid(rod) and Rect2(rod.global_position, rod.size).has_point(pos):
			return true
	return false


func _is_click_on_quick_buttons(pos: Vector2, bar: Control) -> bool:
	for btn in bar.get_quick_buttons():
		if btn and is_instance_valid(btn) and Rect2(btn.global_position, btn.size).has_point(pos):
			return true
	return false


func _is_click_on_water(screen_pos: Vector2) -> bool:
	if not water_zone_node:
		return true
	var poly = water_zone_node.water_polygon
	if not poly:
		return true
	return Geometry2D.is_point_in_polygon(poly.to_local(screen_pos), poly.polygon)


func _cast_float(gear, target_pos: Vector2):
	var float_node = gear.get("float")
	var rod_node = gear.get("rod")
	var label_node = gear.get("label")
	var line_node = gear.get("line")
	if not float_node or not rod_node:
		return
	
	gear["last_cast_pos"] = target_pos
	float_node.visible = true
	if line_node and is_instance_valid(line_node):
		line_node.visible = true
	
	var screen_center_x = get_viewport_rect().size.x / 2.0
	var rod_target_x = target_pos.x + 50 if target_pos.x < screen_center_x else target_pos.x - 50
	
	var tween_rod = create_tween()
	tween_rod.set_parallel(true)
	tween_rod.tween_property(rod_node, "position:x", rod_target_x - 10, 0.2)
	if label_node and is_instance_valid(label_node):
		tween_rod.tween_property(label_node, "position:x", rod_target_x - 13, 0.2)
	
	var tween = create_tween()
	var float_target = target_pos - float_node.size / 2.0
	tween.tween_property(float_node, "position", float_target, 0.5)
	gear["float_original_pos"] = float_target
	tween.tween_callback(_on_cast_complete.bind(gear))


func _on_cast_complete(gear):
	bite_system.start_bite_timer(gear, gear.get("float"), gear.get("float_original_pos"))


func _try_hook():
	var active_gear = _get_active_gear()
	if not active_gear:
		return
	if active_gear.get("is_biting"):
		bite_system.on_hook(active_gear)
		return
	var float_node = active_gear.get("float")
	if float_node and is_instance_valid(float_node) and not float_node.visible:
		var last_pos = active_gear.get("last_cast_pos")
		if last_pos:
			_cast_float(active_gear, last_pos)


func _on_bite_hooked(gear):
	_reset_float_color(gear)
	var water_top = 100.0
	var water_bottom = get_viewport_rect().size.y - 10
	if water_zone_node and water_zone_node.water_polygon:
		var poly = water_zone_node.water_polygon.polygon
		if poly.size() > 0:
			var transform = water_zone_node.water_polygon.get_global_transform()
			water_top = (transform * poly[0]).y
			water_bottom = water_top
			for p in poly:
				var world_y = (transform * p).y
				water_top = minf(water_top, world_y)
				water_bottom = maxf(water_bottom, world_y)
	minigame_ui.start_minigame(gear, gear.get("float"), gear.get("float_original_pos"), water_top, water_bottom)


func _on_bite_missed(gear):
	_reset_float_color(gear)
	retry_timer.timeout.connect(_on_cast_complete.bind(gear), CONNECT_ONE_SHOT)
	retry_timer.start()


func _on_minigame_won(gear):
	var fish = gear.get("current_fish", {})
	var fish_name = fish.get("name", "?")
	var fish_weight = fish.get("caught_weight", fish.get("weight", 0))
	
	var weight_text = ""
	if fish_weight < 1.0:
		weight_text = "%d г" % int(fish_weight * 1000)
	else:
		var kg = int(fish_weight)
		var gr = int((fish_weight - kg) * 1000)
		weight_text = "%d кг %d г" % [kg, gr] if gr > 0 else "%d кг" % kg
	
	var grade = fish.get("grade", "normal")
	var grade_text = ""
	match grade:
		"boss": grade_text = "РЕЙД-БОСС"
		"mega": grade_text = "МЕГАМУТАНТ"
		"trophy": grade_text = "ТРОФЕЙ"
	
	var msg_text = "Поймал %s %s" % [fish_name, weight_text]
	if grade_text != "":
		msg_text += " [%s]" % grade_text
	
	var msg_type = 0
	match grade:
		"trophy": msg_type = 3
		"mega": msg_type = 4
		"boss": msg_type = 5
	
	var msg_panel = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
	if msg_panel and msg_panel.has_method("add_message"):
		msg_panel.add_message(msg_text, msg_type)
	
	_hide_float_and_line(gear)
	_reset_gear(gear)


func _on_minigame_lost(gear, reason):
	var msg_panel = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
	if msg_panel and msg_panel.has_method("add_message"):
		msg_panel.add_message(reason, 2)
	_hide_float_and_line(gear)
	_reset_gear(gear)


func _hide_float_and_line(gear):
	var float_node = gear.get("float")
	var line_node = gear.get("line")
	if float_node and is_instance_valid(float_node):
		float_node.visible = false
	if line_node and is_instance_valid(line_node):
		line_node.visible = false


func _reset_float_color(gear):
	var float_node = gear.get("float")
	if float_node and is_instance_valid(float_node):
		var slot = gear.get("slot", 0)
		float_node.color = Color(1.0, 0.0 + slot * 0.2, 0.0 + slot * 0.2, 1)


func _reset_gear(gear):
	_reset_float_color(gear)
	gear["current_fish"] = null
	gear["is_biting"] = false


func _update_line(gear):
	var rod_node = gear.get("rod")
	var float_node = gear.get("float")
	var line_node = gear.get("line")
	if not rod_node or not float_node or not line_node:
		return
	if not is_instance_valid(rod_node) or not is_instance_valid(float_node) or not is_instance_valid(line_node):
		return
	if not float_node.visible:
		return
	
	var rod_tip = rod_node.position + Vector2(rod_node.size.x / 2, 0)
	var float_center = float_node.position + float_node.size / 2
	line_node.set_point_position(0, rod_tip)
	line_node.set_point_position(1, float_center)
