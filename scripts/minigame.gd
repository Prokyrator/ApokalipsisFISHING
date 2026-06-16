extends Control

signal minigame_won(gear)
signal minigame_lost(gear, reason)

var all_minigames: Dictionary = {}
var current_slot: int = -1
var cut_timers: Dictionary = {}

const BASE_SNAG_CHANCE = 2.5
const CHECKPOINTS = [0.2, 0.4, 0.6, 0.8, 0.95]
const STAMINA_BAR_WIDTH = 40
const STAMINA_BAR_HEIGHT = 6
const BAR_WIDTH = 300
const BAR_HEIGHT = 20
const CUT_HOLD_TIME = 2.0
const B = 1.667

var rod_frame: Panel = null
var rod_bar_bg: Panel = null
var rod_bar_fill: Panel = null
var reel_frame: Panel = null
var reel_bar_bg: Panel = null
var reel_bar_fill: Panel = null

var bars_created: bool = false


func start_minigame(gear, float_node, _float_original_pos, water_top: float = 100.0, water_bottom: float = 710.0):
	if not gear or typeof(gear) != TYPE_DICTIONARY or not float_node:
		return
	
	var fish = gear["current_fish"]
	if not fish:
		return
	
	var slot = gear.get("slot", 0)
	if all_minigames.has(slot):
		_cleanup_slot(slot)
	
	if not bars_created:
		_create_bars()
	
	var stamina_bg = ColorRect.new()
	stamina_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	stamina_bg.size = Vector2(STAMINA_BAR_WIDTH, STAMINA_BAR_HEIGHT)
	stamina_bg.z_index = 5
	add_child(stamina_bg)
	
	var stamina_fill = ColorRect.new()
	stamina_fill.color = Color(0.0, 1.0, 0.0, 0.9)
	stamina_fill.size = Vector2(STAMINA_BAR_WIDTH, STAMINA_BAR_HEIGHT)
	stamina_fill.z_index = 5
	add_child(stamina_fill)
	
	var fish_power = fish.get("power", 10)
	var fish_weight = fish.get("caught_weight", (fish.get("w_min", 0.1) + fish.get("w_max", 1.0)) / 2.0)
	
	var rod_item = GameData.get_quick_slot_item(slot, GameData.GearType.ROD)
	var reel_item = GameData.get_quick_slot_item(slot, GameData.GearType.REEL)
	var line_item = GameData.get_quick_slot_item(slot, GameData.GearType.LINE)
	
	var rod_limit = rod_item.get("weight_limit", 999) if rod_item else 999
	var reel_limit = reel_item.get("weight_limit", 999) if reel_item else 999
	var line_limit = line_item.get("weight_limit", 999) if line_item else 999
	
	var gear_limit = min(rod_limit, min(reel_limit, line_limit))
	
	var load_pct = (fish_weight / gear_limit) * 100.0
	var thresholds = _get_load_thresholds(load_pct)
	
	var fill_time = B * gear_limit / (fish_weight * fish_power) * thresholds["bar_mult"]
	fill_time = max(fill_time, 0.15)
	var fill_speed = 100.0 / fill_time
	
	var pull_speed = max(10.0, gear_limit * 10.0 / sqrt(fish_weight) * thresholds["pull_mult"])
	var escape_speed = fish_power * 5.0 * sqrt(fish_weight) * thresholds["escape_mult"] * (100.0 / 100.0)
	
	var hook_item = GameData.get_quick_slot_item(slot, GameData.GearType.HOOK)
	var hook_bonus = hook_item.get("snag_reduction", 0.0) if hook_item else 0.0
	var snag_mult = 1.0 - hook_bonus
	
	all_minigames[slot] = {
		"gear": gear, "stamina_bg": stamina_bg, "stamina_fill": stamina_fill,
		"rod_fill": 0.0, "reel_fill": 0.0,
		"rod_fill_speed": fill_speed, "reel_fill_speed": fill_speed,
		"rod_drain_speed": fill_speed, "reel_drain_speed": fill_speed,
		"pull_speed": pull_speed, "escape_speed": escape_speed,
		"float_start_y": float_node.position.y, "float_top_limit": water_top, "float_bottom_limit": water_bottom,
		"active": true, "fish_stamina": 100.0, "gear_limit": gear_limit, "fish_weight": fish_weight,
		"stamina_drain_rate": 15.0 / sqrt(fish_weight),
		"snag_mult": snag_mult, "fish_power": fish_power,
		"passed_checkpoints": [], "progress": 0.0, "float_node": float_node,
		"thresholds": thresholds, "checkpoint_delay": 0.5
	}
	gear["in_minigame"] = true
	current_slot = slot
	_update_bars_display()
	
	cut_timers.erase(slot)
	
	if fill_time < 0.2:
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Леска вот-вот лопнет!!!", 2)
	elif fill_time < 0.5:
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Снасти на пределе! Риск поломки!", 1)
	
	GlobalLogger.log("[Minigame] G - удилище, H - катушка, тащи вниз! Рыба: %s (слот %d) | fill: %.2f сек | pull: %.0f | esc: %.0f" % [fish["name"], slot + 1, fill_time, pull_speed, escape_speed])


func _get_load_thresholds(load_pct: float) -> Dictionary:
	if load_pct <= 50:
		return {"bar_mult": 1.0, "pull_mult": 1.0, "escape_mult": 1.0}
	elif load_pct <= 80:
		return {"bar_mult": 1.5, "pull_mult": 0.8, "escape_mult": 1.5}
	elif load_pct <= 100:
		return {"bar_mult": 2.5, "pull_mult": 0.5, "escape_mult": 2.5}
	elif load_pct <= 150:
		return {"bar_mult": 5.0, "pull_mult": 0.25, "escape_mult": 5.0}
	elif load_pct <= 200:
		return {"bar_mult": 10.0, "pull_mult": 0.1, "escape_mult": 10.0}
	else:
		return {"bar_mult": 25.0, "pull_mult": 0.05, "escape_mult": 25.0}


func _create_bars():
	var screen_size = get_viewport_rect().size
	var bar_x = screen_size.x / 2.0 - BAR_WIDTH / 2.0
	var bar_y_top = screen_size.y - 136
	var bar_y_bottom = bar_y_top + BAR_HEIGHT + 5
	
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)
	frame_style.border_width_left = 2; frame_style.border_width_right = 2
	frame_style.border_width_top = 2; frame_style.border_width_bottom = 2
	frame_style.border_color = Color(1.0, 0.78, 0.0, 0.8)
	frame_style.set_corner_radius_all(6)
	
	var bar_bg_style = StyleBoxFlat.new()
	bar_bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bar_bg_style.set_corner_radius_all(5)
	
	var bar_fill_style = StyleBoxFlat.new()
	bar_fill_style.bg_color = Color(0.2, 1.0, 0.2, 0.9)
	bar_fill_style.set_corner_radius_all(5)
	
	rod_frame = _create_bar_element(frame_style, bar_x, bar_y_top, true)
	rod_bar_bg = _create_bar_element(bar_bg_style, bar_x, bar_y_top, false)
	rod_bar_fill = _create_bar_element(bar_fill_style, bar_x, bar_y_top, false)
	rod_bar_fill.clip_contents = true
	
	reel_frame = _create_bar_element(frame_style, bar_x, bar_y_bottom, true)
	reel_bar_bg = _create_bar_element(bar_bg_style, bar_x, bar_y_bottom, false)
	reel_bar_fill = _create_bar_element(bar_fill_style, bar_x, bar_y_bottom, false)
	reel_bar_fill.clip_contents = true
	
	bars_created = true


func _create_bar_element(style: StyleBoxFlat, x: float, y: float, is_frame: bool) -> Panel:
	var panel = Panel.new()
	panel.size = Vector2(BAR_WIDTH + (4 if is_frame else 0), BAR_HEIGHT + (4 if is_frame else 0))
	panel.position = Vector2(x - (2 if is_frame else 0), y - (2 if is_frame else 0))
	panel.z_index = 10
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	return panel


func set_active_slot(slot: int):
	if current_slot != slot:
		current_slot = slot
		_update_bars_display()


func _update_bars_display():
	if not bars_created:
		return
	var mg = all_minigames.get(current_slot)
	var bars_visible = mg != null and mg.get("active")
	for bar in [rod_frame, rod_bar_bg, rod_bar_fill, reel_frame, reel_bar_bg, reel_bar_fill]:
		if bar: bar.visible = bars_visible


func _process(_delta):
	for slot in all_minigames.keys():
		var mg = all_minigames[slot]
		if mg.get("active"):
			_process_single_minigame(mg, slot, _delta)
	_update_bars_display()


func _process_single_minigame(mg, slot: int, _delta):
	var float_node = mg.get("float_node")
	if not float_node or not is_instance_valid(float_node):
		return
	
	# Задержка перед проверками рубежей
	if mg.get("checkpoint_delay", 0) > 0:
		mg["checkpoint_delay"] -= _delta
	
	if slot == current_slot:
		if Input.is_key_pressed(KEY_R):
			if not cut_timers.has(slot):
				cut_timers[slot] = 0.0
			cut_timers[slot] += _delta
			if cut_timers[slot] >= CUT_HOLD_TIME:
				_cut_line(slot)
				return
		else:
			cut_timers.erase(slot)
	
	var f_pressed = Input.is_key_pressed(KEY_G) if slot == current_slot else false
	var g_pressed = Input.is_key_pressed(KEY_H) if slot == current_slot else false
	var any_pressed = f_pressed or g_pressed
	
	if any_pressed:
		mg["fish_stamina"] = maxf(0.0, mg["fish_stamina"] - _delta * mg["stamina_drain_rate"])
	
	_update_stamina_bar(mg, float_node)
	
	var stamina_pct = mg["fish_stamina"] / 100.0
	var current_escape_speed = mg["escape_speed"] * stamina_pct
	mg["rod_fill"] = clampf(mg["rod_fill"] + (mg["rod_fill_speed"] if f_pressed else -mg["rod_drain_speed"]) * _delta, 0.0, 100.0)
	mg["reel_fill"] = clampf(mg["reel_fill"] + (mg["reel_fill_speed"] if g_pressed else -mg["reel_drain_speed"]) * _delta, 0.0, 100.0)
	
	if slot == current_slot:
		_update_bar_fills(mg)
	
	float_node.position.y += (mg["pull_speed"] if any_pressed else -current_escape_speed) * _delta
	var total_distance = mg["float_bottom_limit"] - mg["float_top_limit"]
	mg["progress"] = (float_node.position.y - mg["float_top_limit"]) / total_distance if total_distance > 0 else 0.0
	float_node.position.y = clampf(float_node.position.y, mg["float_top_limit"], mg["float_bottom_limit"])
	
	for cp in CHECKPOINTS:
		if mg["progress"] >= cp and not cp in mg["passed_checkpoints"]:
			mg["passed_checkpoints"].append(cp)
			_check_snag(mg, slot, cp)
			if not mg.get("active"): return
	
	if float_node.position.y >= mg["float_bottom_limit"]:
		var gear = mg["gear"]
		var fish = gear.get("current_fish", {})
		var drop = fish.get("mutagen_drop", 0)
		GameData.mutagens += drop
		minigame_won.emit(gear)
		var fish_data = {
			"name": fish["name"],
			"caught_weight": fish.get("caught_weight", 0),
			"grade": fish.get("grade", "normal"),
			"rarity": fish.get("rarity", 1)
		}
		if not GameData.add_fish_to_cage(fish_data):
			var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
			if msg and msg.has_method("add_message"):
				msg.add_message("Садок переполнен!", 2)
		_cleanup_slot(slot)
	elif mg["rod_fill"] >= 100.0:
		var broken = GameData.damage_item_in_slot(slot, GameData.GearType.ROD)
		minigame_lost.emit(mg["gear"], "Удилище сломалось!" if broken else "Удилище повреждено!")
		_cleanup_slot(slot)
	elif mg["reel_fill"] >= 100.0:
		var broken = GameData.damage_item_in_slot(slot, GameData.GearType.REEL)
		minigame_lost.emit(mg["gear"], "Катушка сломалась!" if broken else "Катушка повреждена!")
		_cleanup_slot(slot)


func _cut_line(slot: int):
	var mg = all_minigames.get(slot)
	if not mg or not mg.get("active"):
		return
	
	GameData.break_line_in_slot(slot)
	minigame_lost.emit(mg["gear"], "Леска обрезана!")
	_cleanup_slot(slot)
	cut_timers.erase(slot)


func _update_stamina_bar(mg, float_node):
	var fill = mg.get("stamina_fill")
	if not fill or not is_instance_valid(fill):
		return
	fill.size.x = STAMINA_BAR_WIDTH * mg["fish_stamina"] / 100.0
	fill.position = float_node.position + Vector2(-STAMINA_BAR_WIDTH / 2.0 + float_node.size.x / 2.0, -12)
	var bg = mg.get("stamina_bg")
	if bg and is_instance_valid(bg):
		bg.position = fill.position
	var s = mg["fish_stamina"] / 100.0
	fill.color = Color(1.0 - s, s, 0.0, 0.9)


func _update_bar_fills(mg):
	if not bars_created: return
	rod_bar_fill.size.x = BAR_WIDTH * mg["rod_fill"] / 100.0
	reel_bar_fill.size.x = BAR_WIDTH * mg["reel_fill"] / 100.0
	rod_bar_fill.add_theme_stylebox_override("panel", _make_fill_style(mg["rod_fill"]))
	reel_bar_fill.add_theme_stylebox_override("panel", _make_fill_style(mg["reel_fill"]))


func _make_fill_style(fill: float) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = _get_fill_color(fill)
	style.set_corner_radius_all(5)
	return style


func _check_snag(mg, slot: int, checkpoint: float):
	if not mg.get("active"): return
	var snag_chance = clampf(BASE_SNAG_CHANCE * (mg["fish_power"] / 10.0) * mg["snag_mult"] * (mg["fish_stamina"] / 100.0), 0.01, 100.0)
	var roll = randf() * 100.0
	GlobalLogger.log("[Minigame] Слот %d | Рубеж %d%% | шанс: %.1f%% | бросок: %.1f | силы: %d%%" % [slot + 1, int(checkpoint * 100), snag_chance, roll, int(mg["fish_stamina"])])
	if roll < snag_chance:
		GlobalLogger.log("[Minigame] СРЫВ! Слот %d на рубеже %d%%!" % [slot + 1, int(checkpoint * 100)])
		minigame_lost.emit(mg["gear"], "Рыба сорвалась!")
		_cleanup_slot(slot)
	else:
		GlobalLogger.log("[Minigame] Рубеж пройден! Слот %d" % (slot + 1))


func _cleanup_slot(slot: int):
	var mg = all_minigames.get(slot)
	if not mg: return
	mg["active"] = false
	if mg.get("gear") and typeof(mg["gear"]) == TYPE_DICTIONARY:
		mg["gear"]["in_minigame"] = false
	for key in ["stamina_bg", "stamina_fill"]:
		var node = mg.get(key)
		if node and is_instance_valid(node): node.queue_free()
	all_minigames.erase(slot)
	cut_timers.erase(slot)
	if current_slot == slot: _update_bars_display()


func cleanup(gear):
	if not gear: return
	_cleanup_slot(gear.get("slot", -1))
	if all_minigames.is_empty() and bars_created:
		for bar in [rod_frame, rod_bar_bg, rod_bar_fill, reel_frame, reel_bar_bg, reel_bar_fill]:
			if bar: bar.visible = false
		current_slot = -1


func _get_fill_color(fill: float) -> Color:
	if fill < 50.0: return Color(0.2, 1.0, 0.2, 0.9)
	elif fill < 80.0: return Color(1.0, 0.9, 0.2, 0.9)
	else: return Color(1.0, 0.2, 0.2, 0.9)
