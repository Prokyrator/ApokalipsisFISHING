extends Control

var content_box: VBoxContainer
var caps_label: Label
var scroll_container: ScrollContainer
var repair_all_btn: Button
var total_cost_label: Label

const SLOT_HEIGHT = 55
const SLOT_GAP = 4
const BTN_X = 760  # единый X для кнопок "Починить" и "Починить всё"

var current_mode: String = ""


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
	
	caps_label = Label.new()
	caps_label.text = "Мои крышечки: %d" % GameData.caps
	caps_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	caps_label.add_theme_font_size_override("font_size", 18)
	caps_label.position = Vector2(15, 15)
	caps_label.size = Vector2(250, 30)
	add_child(caps_label)
	
	var title = Label.new()
	title.text = "ВЕРСТАК"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(300, 40)
	title.position = Vector2(370, 10)
	add_child(title)
	
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
	
	var mode_btn_style = StyleBoxFlat.new()
	mode_btn_style.bg_color = Color(0.25, 0.25, 0.25, 0.8)
	mode_btn_style.border_width_left = 2
	mode_btn_style.border_width_right = 2
	mode_btn_style.border_width_top = 2
	mode_btn_style.border_width_bottom = 2
	mode_btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	mode_btn_style.set_corner_radius_all(6)
	
	var modes = [
		{"text": "ПОЧИНИТЬ", "x": 150},
		{"text": "КРАФТ", "x": 400},
		{"text": "УЛУЧШИТЬ", "x": 650},
	]
	
	for md in modes:
		var btn = Button.new()
		btn.text = md["text"]
		btn.custom_minimum_size = Vector2(200, 50)
		btn.position = Vector2(md["x"], 60)
		btn.add_theme_stylebox_override("normal", mode_btn_style)
		btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.9))
		btn.add_theme_font_size_override("font_size", 18)
		btn.pressed.connect(_on_mode_pressed.bind(md["text"]))
		add_child(btn)
	
	# Кнопка "Починить всё" и цена — внизу справа
	total_cost_label = Label.new()
	total_cost_label.text = "0 🧢"
	total_cost_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	total_cost_label.add_theme_font_size_override("font_size", 16)
	total_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	total_cost_label.position = Vector2(BTN_X - 120, 575)
	total_cost_label.size = Vector2(110, 35)
	total_cost_label.visible = false
	add_child(total_cost_label)
	
	repair_all_btn = Button.new()
	repair_all_btn.text = "Починить всё"
	repair_all_btn.custom_minimum_size = Vector2(160, 40)
	repair_all_btn.position = Vector2(BTN_X, 570)
	var ra_style = StyleBoxFlat.new()
	ra_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	ra_style.border_width_left = 2
	ra_style.border_width_right = 2
	ra_style.border_width_top = 2
	ra_style.border_width_bottom = 2
	ra_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	ra_style.set_corner_radius_all(6)
	repair_all_btn.add_theme_stylebox_override("normal", ra_style)
	repair_all_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	repair_all_btn.add_theme_font_size_override("font_size", 14)
	repair_all_btn.pressed.connect(_on_repair_all_pressed)
	repair_all_btn.visible = false
	add_child(repair_all_btn)
	
	scroll_container = ScrollContainer.new()
	scroll_container.size = Vector2(1000, 430)
	scroll_container.position = Vector2(20, 120)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.visible = false
	add_child(scroll_container)
	
	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", SLOT_GAP)
	content_box.custom_minimum_size = Vector2(980, 0)
	scroll_container.add_child(content_box)


func _on_mode_pressed(mode: String):
	current_mode = mode
	repair_all_btn.visible = (mode == "ПОЧИНИТЬ")
	total_cost_label.visible = (mode == "ПОЧИНИТЬ")
	scroll_container.visible = (mode == "ПОЧИНИТЬ")
	_populate_items()


func _populate_items():
	for child in content_box.get_children():
		child.queue_free()
	
	var total_cost = 0
	
	if current_mode == "ПОЧИНИТЬ":
		for i in range(GameData.inventory.size()):
			var item = GameData.inventory[i]
			var max_dura = item.get("max_durability", 0)
			var cur_dura = item.get("durability", 0)
			if max_dura <= 0 or cur_dura >= max_dura:
				continue
			
			var rarity = item.get("rarity", 1)
			var cost = int((max_dura - cur_dura) * pow(2, rarity - 1))
			total_cost += cost
			
			var slot = _create_repair_slot(i, item, cost)
			content_box.add_child(slot)
	
	total_cost_label.text = "%d 🧢" % total_cost


func _create_repair_slot(index: int, item: Dictionary, cost: int) -> Control:
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(980, SLOT_HEIGHT)
	
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.9)
	bg.size = Vector2(980, SLOT_HEIGHT)
	bg.position = Vector2.ZERO
	slot.add_child(bg)
	
	var rarity_color = GameData.get_rarity_color(item.get("rarity", 1))
	
	var label = Label.new()
	label.text = "[%s] %s" % [GameData.get_rarity_name(item.get("rarity", 1)), item.get("name", "???")]
	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(10, 5)
	label.size = Vector2(350, 25)
	slot.add_child(label)
	
	var dura_label = Label.new()
	dura_label.text = "Прочность: %d/%d" % [item.get("durability", 0), item.get("max_durability", 0)]
	dura_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.9))
	dura_label.add_theme_font_size_override("font_size", 14)
	dura_label.position = Vector2(10, 30)
	dura_label.size = Vector2(250, 20)
	slot.add_child(dura_label)
	
	var cost_label = Label.new()
	cost_label.text = "%d 🧢" % cost
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	cost_label.add_theme_font_size_override("font_size", 16)
	cost_label.position = Vector2(600, 12)
	cost_label.size = Vector2(100, 30)
	slot.add_child(cost_label)
	
	var repair_btn = Button.new()
	repair_btn.text = "Починить"
	repair_btn.custom_minimum_size = Vector2(130, 35)
	repair_btn.position = Vector2(BTN_X, 10)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(4)
	repair_btn.add_theme_stylebox_override("normal", btn_style)
	repair_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	repair_btn.add_theme_font_size_override("font_size", 13)
	repair_btn.pressed.connect(_on_repair_pressed.bind(index, cost))
	slot.add_child(repair_btn)
	
	return slot


func _on_repair_pressed(index: int, cost: int):
	if GameData.caps >= cost:
		GameData.caps -= cost
		GameData.inventory[index]["durability"] = GameData.inventory[index]["max_durability"]
		GameData._save_data()
		_populate_items()
		caps_label.text = "Мои крышечки: %d" % GameData.caps
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Отремонтировано!", 0)
	else:
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Не хватает крышечек!", 2)


func _on_repair_all_pressed():
	var total_cost = 0
	var items_to_repair = []
	
	for i in range(GameData.inventory.size()):
		var item = GameData.inventory[i]
		var max_dura = item.get("max_durability", 0)
		var cur_dura = item.get("durability", 0)
		if max_dura <= 0 or cur_dura >= max_dura:
			continue
		var rarity = item.get("rarity", 1)
		var cost = int((max_dura - cur_dura) * pow(2, rarity - 1))
		total_cost += cost
		items_to_repair.append({"index": i, "cost": cost})
	
	if items_to_repair.is_empty():
		return
	
	if GameData.caps >= total_cost:
		GameData.caps -= total_cost
		for repair in items_to_repair:
			GameData.inventory[repair["index"]]["durability"] = GameData.inventory[repair["index"]]["max_durability"]
		GameData._save_data()
		_populate_items()
		caps_label.text = "Мои крышечки: %d" % GameData.caps
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Всё отремонтировано!", 0)
	else:
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Не хватает крышечек!", 2)


func _on_close_pressed():
	visible = false


func refresh():
	caps_label.text = "Мои крышечки: %d" % GameData.caps
