extends Control

var content_box: VBoxContainer
var scroll_container: ScrollContainer
var info_label: Label
var sell_all_btn: Button

const SLOT_HEIGHT = 40
const SLOT_GAP = 3


func _ready():
	visible = false
	_build_window()


func _build_window():
	custom_minimum_size = Vector2(1040, 620)
	position = Vector2(120, 100)
	
	var panel = Panel.new()
	panel.size = Vector2(1040, 620)
	panel.position = Vector2.ZERO
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
	panel_style.border_width_left = 4
	panel_style.border_width_right = 4
	panel_style.border_width_top = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1.0, 0.78, 0.0, 1.0)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)
	
	var title = Label.new()
	title.text = "САДОК"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1040, 40)
	title.position = Vector2(0, 10)
	add_child(title)
	
	info_label = Label.new()
	info_label.text = "Рыб: 0 / %d" % GameData.cage_capacity
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
	info_label.add_theme_font_size_override("font_size", 14)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	info_label.size = Vector2(250, 30)
	info_label.position = Vector2(720, 15)
	add_child(info_label)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.position = Vector2(990, 10)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.8, 0.2, 0.2, 0.9)
	close_style.set_corner_radius_all(6)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.pressed.connect(_on_close_pressed)
	add_child(close_btn)
	
	sell_all_btn = Button.new()
	sell_all_btn.text = "Продать всё"
	sell_all_btn.custom_minimum_size = Vector2(180, 40)
	sell_all_btn.position = Vector2(830, 560)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.8, 0.3, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(6)
	sell_all_btn.add_theme_stylebox_override("normal", btn_style)
	sell_all_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	sell_all_btn.add_theme_font_size_override("font_size", 14)
	sell_all_btn.pressed.connect(_on_sell_all_pressed)
	add_child(sell_all_btn)
	
	scroll_container = ScrollContainer.new()
	scroll_container.size = Vector2(1000, 485)
	scroll_container.position = Vector2(20, 55)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll_container)
	
	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", SLOT_GAP)
	content_box.custom_minimum_size = Vector2(980, 0)
	scroll_container.add_child(content_box)


func _populate_items():
	for child in content_box.get_children():
		child.queue_free()
	
	info_label.text = "Рыб: %d / %d" % [GameData.fish_cage.size(), GameData.cage_capacity]
	
	var total_price = 0
	for fish in GameData.fish_cage:
		var w = fish.get("caught_weight", 0)
		var g = fish.get("grade", "normal")
		var r = fish.get("rarity", 1)
		var gm = 1.0
		match g:
			"boss": gm = 25.0
			"mega": gm = 8.0
			"trophy": gm = 3.0
		var rm = 1.0
		if r == 2: rm = 3.0
		elif r == 3: rm = 10.0
		total_price += int(w * 5 * gm * rm)
	sell_all_btn.text = "Продать всё (%d 🧢)" % total_price
	
	for i in range(GameData.fish_cage.size()):
		var fish = GameData.fish_cage[i]
		var slot = _create_fish_slot(i, fish)
		content_box.add_child(slot)


func _create_fish_slot(index: int, fish: Dictionary) -> Control:
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(980, SLOT_HEIGHT)
	
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.9)
	bg.size = Vector2(980, SLOT_HEIGHT)
	bg.position = Vector2.ZERO
	slot.add_child(bg)
	
	var grade = fish.get("grade", "normal")
	var grade_color = FishData.get_grade_color(grade)
	var rarity = fish.get("rarity", 1)
	var rarity_color = GameData.get_rarity_color(rarity)
	
	var label = Label.new()
	label.text = fish.get("name", "???")
	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_font_size_override("font_size", 15)
	label.position = Vector2(10, 3)
	label.size = Vector2(250, 22)
	slot.add_child(label)
	
	var weight = fish.get("caught_weight", 0)
	var weight_text = ""
	if weight < 1.0:
		weight_text = "%d г" % int(weight * 1000)
	else:
		var kg = int(weight)
		var gr = int((weight - kg) * 1000)
		weight_text = "%d кг %d г" % [kg, gr] if gr > 0 else "%d кг" % kg
	
	var weight_label = Label.new()
	weight_label.text = weight_text
	weight_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	weight_label.add_theme_font_size_override("font_size", 14)
	weight_label.position = Vector2(330, 5)
	weight_label.size = Vector2(150, 20)
	slot.add_child(weight_label)
	
	var grade_text = ""
	match grade:
		"boss": grade_text = "РЕЙД-БОСС"
		"mega": grade_text = "МЕГАМУТАНТ"
		"trophy": grade_text = "ТРОФЕЙ"
	
	if grade_text != "":
		var grade_label = Label.new()
		grade_label.text = grade_text
		grade_label.add_theme_color_override("font_color", grade_color)
		grade_label.add_theme_font_size_override("font_size", 12)
		grade_label.position = Vector2(550, 5)
		grade_label.size = Vector2(120, 20)
		slot.add_child(grade_label)
	
	var base_rate = 5
	var grade_mult = 1.0
	match grade:
		"boss": grade_mult = 25.0
		"mega": grade_mult = 8.0
		"trophy": grade_mult = 3.0
	
	var rarity_mult = 1.0
	if rarity == 2: rarity_mult = 3.0
	elif rarity == 3: rarity_mult = 10.0
	
	var price = int(weight * base_rate * grade_mult * rarity_mult)
	
	var price_label = Label.new()
	price_label.text = "%d 🧢" % price
	price_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	price_label.add_theme_font_size_override("font_size", 14)
	price_label.position = Vector2(730, 5)
	price_label.size = Vector2(100, 20)
	slot.add_child(price_label)
	
	var sell_btn = Button.new()
	sell_btn.text = "Продать"
	sell_btn.custom_minimum_size = Vector2(80, 30)
	sell_btn.position = Vector2(870, 5)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.8, 0.3, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(4)
	sell_btn.add_theme_stylebox_override("normal", btn_style)
	sell_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	sell_btn.add_theme_font_size_override("font_size", 12)
	sell_btn.pressed.connect(_on_sell_fish_pressed.bind(index))
	slot.add_child(sell_btn)
	
	return slot


func _on_sell_fish_pressed(index: int):
	if index < 0 or index >= GameData.fish_cage.size():
		return
	
	var fish = GameData.fish_cage[index]
	var w = fish.get("caught_weight", 0)
	var g = fish.get("grade", "normal")
	var r = fish.get("rarity", 1)
	var gm = 1.0
	match g:
		"boss": gm = 25.0
		"mega": gm = 8.0
		"trophy": gm = 3.0
	var rm = 1.0
	if r == 2: rm = 3.0
	elif r == 3: rm = 10.0
	var price = int(w * 5 * gm * rm)
	
	GameData.caps += price
	GameData.fish_cage.remove_at(index)
	GameData._save_data()
	_populate_items()
	
	var iface = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
	if iface and iface.has_method("rebuild_player_info"):
		iface.rebuild_player_info()
	if iface and iface.has_method("update_cage_button"):
		iface.update_cage_button()
	
	var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
	if msg and msg.has_method("add_message"):
		msg.add_message("Продано за %d 🧢" % price, 0)


func _on_sell_all_pressed():
	if GameData.fish_cage.is_empty():
		return
	
	var total = 0
	for fish in GameData.fish_cage:
		var w = fish.get("caught_weight", 0)
		var g = fish.get("grade", "normal")
		var r = fish.get("rarity", 1)
		var gm = 1.0
		match g:
			"boss": gm = 25.0
			"mega": gm = 8.0
			"trophy": gm = 3.0
		var rm = 1.0
		if r == 2: rm = 3.0
		elif r == 3: rm = 10.0
		total += int(w * 5 * gm * rm)
	
	GameData.caps += total
	GameData.fish_cage.clear()
	GameData._save_data()
	_populate_items()
	
	var iface = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
	if iface and iface.has_method("rebuild_player_info"):
		iface.rebuild_player_info()
	if iface and iface.has_method("update_cage_button"):
		iface.update_cage_button()
	
	var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
	if msg and msg.has_method("add_message"):
		msg.add_message("Продано всё за %d 🧢" % total, 0)


func _on_close_pressed():
	visible = false
	var iface = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
	if iface and iface.has_method("update_cage_button"):
		iface.update_cage_button()


func refresh():
	_populate_items()
