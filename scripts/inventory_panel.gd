extends Control

var scroll_container: ScrollContainer
var content_box: VBoxContainer
var item_slots: Array = []
var selected_category: int = 0
var tooltip: Control = null

const SLOT_HEIGHT = 50
const SLOT_GAP = 4
const MENU_WIDTH = 160

var menu_buttons: Array = []


func _ready():
	visible = false
	_build_window()
	_populate_items()
	if menu_buttons.size() > 0:
		_on_category_pressed(GameData.GearType.ROD)


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
	title.text = "ИНВЕНТАРЬ"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1040, 50)
	title.position = Vector2(0, 10)
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
	
	_build_menu()
	
	scroll_container = ScrollContainer.new()
	scroll_container.size = Vector2(840, 520)
	scroll_container.position = Vector2(MENU_WIDTH + 20, 70)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	
	var scroll_style = StyleBoxFlat.new()
	scroll_style.bg_color = Color(0.1, 0.1, 0.1, 1)
	scroll_style.border_width_left = 2
	scroll_style.border_width_right = 2
	scroll_style.border_width_top = 2
	scroll_style.border_width_bottom = 2
	scroll_style.border_color = Color(1.0, 0.78, 0.0, 1)
	scroll_style.set_corner_radius_all(4)
	scroll_container.add_theme_stylebox_override("panel", scroll_style)
	add_child(scroll_container)
	
	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", SLOT_GAP)
	content_box.custom_minimum_size = Vector2(820, 0)
	scroll_container.add_child(content_box)


func _build_menu():
	var categories = [
		{"name": "Удилища", "type": GameData.GearType.ROD},
		{"name": "Катушки", "type": GameData.GearType.REEL},
		{"name": "Лески", "type": GameData.GearType.LINE},
		{"name": "Крючки", "type": GameData.GearType.HOOK},
		{"name": "Наживки", "type": GameData.GearType.BAIT},
		{"name": "Садки", "type": GameData.GearType.CAGE},
	]
	
	for i in range(categories.size()):
		var cat = categories[i]
		var btn = Button.new()
		btn.text = cat["name"]
		btn.custom_minimum_size = Vector2(MENU_WIDTH - 20, 40)
		btn.position = Vector2(10, 70 + i * 46)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.25, 0.25, 0.25, 0.8)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(1.0, 0.78, 0.0, 0.4)
		style.set_corner_radius_all(4)
		btn.add_theme_stylebox_override("normal", style)
		
		var hover_style = style.duplicate()
		hover_style.bg_color = Color(0.4, 0.4, 0.4, 0.9)
		hover_style.border_color = Color(1.0, 0.9, 0.0, 0.8)
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(_on_category_pressed.bind(cat["type"]))
		add_child(btn)
		menu_buttons.append(btn)


func _on_category_pressed(cat_type: int):
	selected_category = cat_type
	_populate_items()
	
	for btn in menu_buttons:
		var style = btn.get_theme_stylebox("normal").duplicate()
		style.bg_color = Color(0.25, 0.25, 0.25, 0.8)
		style.border_color = Color(1.0, 0.78, 0.0, 0.4)
		btn.add_theme_stylebox_override("normal", style)


func _populate_items():
	for slot in item_slots:
		if slot and is_instance_valid(slot):
			slot.queue_free()
	item_slots.clear()
	
	for i in range(GameData.inventory.size()):
		var item = GameData.inventory[i]
		if item.get("type") != selected_category:
			GlobalLogger.log("[Inventory] item: %s, type: %d" % [item.get("name"), item.get("type")])
			continue
		var slot = _create_item_slot(item)
		content_box.add_child(slot)
		item_slots.append(slot)


func _create_item_slot(item: Dictionary) -> Control:
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(820, SLOT_HEIGHT)
	
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.2, 0.9)
	bg.size = Vector2(820, SLOT_HEIGHT)
	bg.position = Vector2.ZERO
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(bg)
	
	var rarity_color = GameData.get_rarity_color(item.get("rarity", 1))
	
	var label = Label.new()
	label.text = item.get("name", "???")
	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(10, 5)
	label.size = Vector2(300, 25)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(label)
	
	var rarity_label = Label.new()
	rarity_label.text = GameData.get_rarity_name(item.get("rarity", 1))
	rarity_label.add_theme_color_override("font_color", rarity_color)
	rarity_label.add_theme_font_size_override("font_size", 20)
	rarity_label.position = Vector2(310, 8)
	rarity_label.size = Vector2(40, 25)
	rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(rarity_label)
	
	if item.get("type") == GameData.GearType.BAIT:
		var qty_label = Label.new()
		qty_label.text = "×%d" % item.get("quantity", 0)
		qty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.9))
		qty_label.add_theme_font_size_override("font_size", 16)
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_label.position = Vector2(700, 8)
		qty_label.size = Vector2(110, 25)
		qty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(qty_label)
	elif item.get("type") == GameData.GearType.CAGE:
		var cap_label = Label.new()
		cap_label.text = "Вместимость: %d рыб" % item.get("capacity", 0)
		cap_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.9))
		cap_label.add_theme_font_size_override("font_size", 14)
		cap_label.position = Vector2(10, 30)
		cap_label.size = Vector2(200, 20)
		cap_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(cap_label)
		
		# Кнопка Надеть
		var equip_btn = Button.new()
		if item.get("active"):
			equip_btn.text = "Надет"
			equip_btn.disabled = true
		else:
			equip_btn.text = "Надеть"
		equip_btn.custom_minimum_size = Vector2(80, 30)
		equip_btn.position = Vector2(700, 8)
		var eq_style = StyleBoxFlat.new()
		eq_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
		eq_style.border_width_left = 2
		eq_style.border_width_right = 2
		eq_style.border_width_top = 2
		eq_style.border_width_bottom = 2
		eq_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
		eq_style.set_corner_radius_all(4)
		equip_btn.add_theme_stylebox_override("normal", eq_style)
		equip_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		equip_btn.add_theme_font_size_override("font_size", 12)
		equip_btn.pressed.connect(_on_equip_cage_pressed.bind(item))
		slot.add_child(equip_btn)
	else:
		var params_text = "Срыв: -%d%%" % int(item.get("snag_reduction", 0.1) * 100) if item.get("type") == GameData.GearType.HOOK else "Вес: %.0f кг" % item.get("weight_limit", 0)
		var params_label = Label.new()
		params_label.text = params_text
		params_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.9))
		params_label.add_theme_font_size_override("font_size", 14)
		params_label.position = Vector2(10, 30)
		params_label.size = Vector2(300, 20)
		params_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(params_label)
	
	if item.get("max_durability", 0) > 0:
		var dura_label = Label.new()
		dura_label.text = "Прочность: %d/%d" % [item.get("durability", 0), item.get("max_durability", 0)]
		dura_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.9))
		dura_label.add_theme_font_size_override("font_size", 12)
		dura_label.position = Vector2(400, 30)
		dura_label.size = Vector2(200, 20)
		dura_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(dura_label)
	
	slot.mouse_entered.connect(_on_slot_mouse_entered.bind(item))
	slot.mouse_exited.connect(_on_slot_mouse_exited)
	
	return slot


func _get_type_name(type: int) -> String:
	match type:
		GameData.GearType.ROD: return "Удилище"
		GameData.GearType.REEL: return "Катушка"
		GameData.GearType.LINE: return "Леска"
		GameData.GearType.HOOK: return "Крючок"
		GameData.GearType.BAIT: return "Наживка"
	return "?"


func _on_slot_mouse_entered(item: Dictionary):
	if tooltip:
		tooltip.queue_free()
	
	tooltip = Control.new()
	tooltip.z_index = 200
	
	var rarity_color = GameData.get_rarity_color(item.get("rarity", 1))
	var rarity_name = GameData.get_rarity_name(item.get("rarity", 1))
	
	var lines: Array = []
	lines.append("[%s] %s" % [rarity_name, item.get("name", "???")])
	lines.append(_get_type_name(item.get("type", 0)))
	
	if item.get("type") == GameData.GearType.HOOK:
		lines.append("Срыв: -%d%%" % int(item.get("snag_reduction", 0.1) * 100))
	elif item.get("type") == GameData.GearType.BAIT:
		lines.append("Кол-во: %d" % item.get("quantity", 0))
		lines.append("Скорость: -%d%%" % int((1.0 - item.get("bite_speed", 1.0)) * 100))
	else:
		lines.append("Вес: %.0f кг" % item.get("weight_limit", 0))
	
	if item.get("max_durability", 0) > 0:
		lines.append("Прочность: %d/%d" % [item.get("durability", 0), item.get("max_durability", 0)])
	
	lines.append(item.get("description", ""))
	
	var y_offset = 5.0
	var line_height = 22.0
	
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.05, 0.95)
	bg.size = Vector2(300, lines.size() * line_height + 10)
	bg.position = Vector2.ZERO
	tooltip.add_child(bg)
	
	var title_label = Label.new()
	title_label.text = lines[0]
	title_label.add_theme_color_override("font_color", rarity_color)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.position = Vector2(10, y_offset)
	title_label.size = Vector2(280, line_height)
	tooltip.add_child(title_label)
	y_offset += line_height
	
	for i in range(1, lines.size()):
		var info_label = Label.new()
		info_label.text = lines[i]
		info_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
		info_label.add_theme_font_size_override("font_size", 12)
		info_label.position = Vector2(10, y_offset)
		info_label.size = Vector2(280, line_height)
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		tooltip.add_child(info_label)
		y_offset += line_height
	
	tooltip.position = get_local_mouse_position() + Vector2(15, 15)
	add_child(tooltip)


func _on_slot_mouse_exited():
	if tooltip:
		tooltip.queue_free()
		tooltip = null


func _on_close_pressed():
	visible = false
	var fishing_layer = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти")
	if fishing_layer:
		fishing_layer.visible = true


func refresh():
	_populate_items()

func _on_equip_cage_pressed(item: Dictionary):
	GlobalLogger.log("[Inventory] Надеваем садок: %s, вместимость: %d" % [item.get("name"), item.get("capacity", 0)])
	var new_capacity = item.get("capacity", 20)
	
	# Ищем старый садок и снимаем метку active
	for inv_item in GameData.inventory:
		if inv_item.get("type") == GameData.GearType.CAGE and inv_item.get("active"):
			inv_item["active"] = false
	
	# Надеваем новый
	item["active"] = true
	GameData.cage_capacity = new_capacity
	
	# Переносим рыбу если не влезает — обрезаем
	while GameData.fish_cage.size() > new_capacity:
		GameData.fish_cage.pop_back()
	
	GameData._save_data()
	_populate_items()
	
	var msg = get_node_or_null("/root/GlobalUi/UILayer/СлойСнасти/MessagePanel")
	if msg and msg.has_method("add_message"):
		msg.add_message("Садок на %d рыб надет!" % new_capacity, 0)
	var iface = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
	if iface and iface.has_method("update_cage_button"):
		iface.update_cage_button()
