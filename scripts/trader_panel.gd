extends Control

var trader_inventory: Array = []
var selected_category: int = 0
var is_buy_mode: bool = true


const MENU_WIDTH = 160
const SLOT_HEIGHT = 55
const SLOT_GAP = 4

var scroll_container: ScrollContainer
var content_box: VBoxContainer
var menu_buttons: Array = []
var caps_label: Label
var buy_btn: Button
var sell_btn: Button


func _ready():
	visible = false
	_load_trader_inventory()
	_build_window()
	_populate_items()
	if menu_buttons.size() > 0:
		_on_category_pressed(GameData.GearType.ROD)


func _load_trader_inventory():
	var file = FileAccess.open("res://data/trader_inventory.json", FileAccess.READ)
	if file:
		var text = file.get_as_text()
		var json = JSON.parse_string(text)
		if json and json is Array:
			trader_inventory = json
		file.close()


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
	
	buy_btn = Button.new()
	buy_btn.text = "КУПИТЬ"
	buy_btn.custom_minimum_size = Vector2(120, 40)
	buy_btn.position = Vector2(300, 15)
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(1.0, 0.78, 0.0, 0.8)
	active_style.set_corner_radius_all(6)
	buy_btn.add_theme_stylebox_override("normal", active_style)
	buy_btn.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	buy_btn.add_theme_font_size_override("font_size", 16)
	buy_btn.pressed.connect(_on_buy_mode_pressed)
	add_child(buy_btn)
	
	var title = Label.new()
	title.text = "ТОРГОВЕЦ"
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(200, 40)
	title.position = Vector2(420, 15)
	add_child(title)
	
	sell_btn = Button.new()
	sell_btn.text = "ПРОДАТЬ"
	sell_btn.custom_minimum_size = Vector2(120, 40)
	sell_btn.position = Vector2(620, 15)
	var inactive_style = StyleBoxFlat.new()
	inactive_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	inactive_style.border_width_left = 2
	inactive_style.border_width_right = 2
	inactive_style.border_width_top = 2
	inactive_style.border_width_bottom = 2
	inactive_style.border_color = Color(1.0, 0.78, 0.0, 0.4)
	inactive_style.set_corner_radius_all(6)
	sell_btn.add_theme_stylebox_override("normal", inactive_style)
	sell_btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.7))
	sell_btn.add_theme_font_size_override("font_size", 16)
	sell_btn.pressed.connect(_on_sell_mode_pressed)
	add_child(sell_btn)
	
	caps_label = Label.new()
	caps_label.text = "Мои крышечки: %d" % GameData.caps
	caps_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	caps_label.add_theme_font_size_override("font_size", 18)
	caps_label.position = Vector2(15, 15)
	caps_label.size = Vector2(250, 30)
	add_child(caps_label)
	
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
		btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(_on_category_pressed.bind(cat["type"]))
		add_child(btn)
		menu_buttons.append(btn)


func _on_buy_mode_pressed():
	is_buy_mode = true
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(1.0, 0.78, 0.0, 0.8)
	active_style.set_corner_radius_all(6)
	buy_btn.add_theme_stylebox_override("normal", active_style)
	buy_btn.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	
	var inactive_style = StyleBoxFlat.new()
	inactive_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	inactive_style.border_width_left = 2
	inactive_style.border_width_right = 2
	inactive_style.border_width_top = 2
	inactive_style.border_width_bottom = 2
	inactive_style.border_color = Color(1.0, 0.78, 0.0, 0.4)
	inactive_style.set_corner_radius_all(6)
	sell_btn.add_theme_stylebox_override("normal", inactive_style)
	sell_btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.7))
	_populate_items()


func _on_sell_mode_pressed():
	is_buy_mode = false
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(1.0, 0.78, 0.0, 0.8)
	active_style.set_corner_radius_all(6)
	sell_btn.add_theme_stylebox_override("normal", active_style)
	sell_btn.add_theme_color_override("font_color", Color(0.0, 0.0, 0.0, 1.0))
	
	var inactive_style = StyleBoxFlat.new()
	inactive_style.bg_color = Color(0.3, 0.3, 0.3, 0.8)
	inactive_style.border_width_left = 2
	inactive_style.border_width_right = 2
	inactive_style.border_width_top = 2
	inactive_style.border_width_bottom = 2
	inactive_style.border_color = Color(1.0, 0.78, 0.0, 0.4)
	inactive_style.set_corner_radius_all(6)
	buy_btn.add_theme_stylebox_override("normal", inactive_style)
	buy_btn.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 0.7))
	_populate_items()


func _on_category_pressed(cat_type: int):
	selected_category = cat_type
	_populate_items()


func _populate_items():
	for child in content_box.get_children():
		child.queue_free()
	
	if is_buy_mode:
		for item in trader_inventory:
			if item.get("type") != selected_category:
				continue
			var slot = _create_buy_slot(item)
			content_box.add_child(slot)
	else:
		for i in range(GameData.inventory.size()):
			var item = GameData.inventory[i]
			if item.get("type") != selected_category:
				continue
			if item.get("type") == GameData.GearType.BAIT:
				continue
			if item.get("starter"):
				continue
			var slot = _create_sell_slot(i, item)
			content_box.add_child(slot)



func _create_buy_slot(item: Dictionary) -> Control:
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
	label.text = "[%s] %s" % [GameData.get_rarity_name(item.get("rarity", 1)), item.get("name", "???")]
	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(10, 5)
	label.size = Vector2(400, 25)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(label)
	
	var price_label = Label.new()
	price_label.text = "%d 🧢" % item.get("price", 0)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.position = Vector2(550, 10)
	price_label.size = Vector2(120, 30)
	price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(price_label)
	
	var btn = Button.new()
	btn.text = "Купить"
	btn.custom_minimum_size = Vector2(100, 35)
	btn.position = Vector2(680, 10)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(_on_buy_pressed.bind(item))
	slot.add_child(btn)
	
	slot.mouse_entered.connect(_on_slot_mouse_entered.bind(item))
	slot.mouse_exited.connect(_on_slot_mouse_exited)
	
	return slot


func _create_sell_slot(index: int, item: Dictionary) -> Control:
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
	label.text = "[%s] %s" % [GameData.get_rarity_name(item.get("rarity", 1)), item.get("name", "???")]
	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_font_size_override("font_size", 16)
	label.position = Vector2(10, 5)
	label.size = Vector2(400, 25)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(label)
	
	var sell_price = 0
	for t_item in trader_inventory:
		if t_item.get("name") == item.get("name") and t_item.get("type") == item.get("type"):
			sell_price = t_item.get("sell_price", t_item.get("price", 0) / 2)
			break
	
	var price_label = Label.new()
	price_label.text = "%d 🧢" % sell_price
	price_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.0, 1.0))
	price_label.add_theme_font_size_override("font_size", 16)
	price_label.position = Vector2(550, 10)
	price_label.size = Vector2(120, 30)
	price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(price_label)
	
	var btn = Button.new()
	btn.text = "Продать"
	btn.custom_minimum_size = Vector2(100, 35)
	btn.position = Vector2(680, 10)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.8, 0.3, 0.2, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(1.0, 0.78, 0.0, 0.6)
	btn_style.set_corner_radius_all(4)
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	btn.add_theme_font_size_override("font_size", 13)
	btn.pressed.connect(_on_sell_pressed.bind(index, sell_price))
	slot.add_child(btn)
	
	slot.mouse_entered.connect(_on_slot_mouse_entered_new.bind(item))
	slot.mouse_exited.connect(_on_slot_mouse_exited_new)
	
	return slot


func _on_buy_pressed(item: Dictionary):
	var price = item.get("price", 0)
	if GameData.caps >= price:
		GameData.caps -= price
		var new_item = item.duplicate()
		GameData.inventory.append(new_item)
		GameData._save_data()
		caps_label.text = "Мои крышечки: %d" % GameData.caps
		var iface = get_node_or_null("/root/GlobalUi/UILayer/СлойИнтерфейса")
		if iface and iface.has_method("rebuild_player_info"):
			iface.rebuild_player_info()
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Куплено: %s" % item["name"], 0)
	else:
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Не хватает крышечек!", 2)


func _on_sell_pressed(index: int, price: int):
	if index >= 0 and index < GameData.inventory.size():
		GameData.caps += price
		GameData.inventory.remove_at(index)
		GameData._save_data()
		caps_label.text = "Мои крышечки: %d" % GameData.caps
		_populate_items()
		var msg = get_node_or_null("/root/GlobalUi/UILayer/MessagePanel")
		if msg and msg.has_method("add_message"):
			msg.add_message("Продано за %d 🧢" % price, 0)


func _on_close_pressed():
	UIManager.toggle_trader()


func refresh():
	caps_label.text = "Мои крышечки: %d" % GameData.caps
	_populate_items()


func _on_slot_mouse_entered_new(item: Dictionary):
	ItemTooltip.show_tooltip(self, item)

func _on_slot_mouse_exited_new():
	ItemTooltip.hide_tooltip(self)
